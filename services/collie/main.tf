module "service" {
  source = "../../modules/aws/ecs/service"

  environment  = var.environment
  service_name = "collie"

  cluster_arn       = var.cluster_arn
  vpc_id            = var.vpc_id
  subnet_ids        = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids

  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
  health_check_path                  = "/health"
}

resource "aws_cloudwatch_log_group" "collie" {
  name              = "/ecs/${var.environment}/collie-server"
  retention_in_days = 30

  tags = {
    Environment = var.environment
    Service     = "collie"
    Terraform   = "true"
  }
}

data "aws_secretsmanager_secret" "oidc_config" {
  name = "/${var.environment}/collie/config"
}

resource "aws_iam_policy" "collie_secrets_policy" {
  name        = "${var.environment}-collie-secrets"
  path        = "/"
  description = "IAM policy for collie server to access required secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = data.aws_secretsmanager_secret.oidc_config.arn
      },
    ]
  })
}

resource "aws_iam_role" "collie_task_role" {
  name = "${var.environment}-collie-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Service     = "collie"
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "collie_secrets_attachment" {
  role       = aws_iam_role.collie_task_role.name
  policy_arn = aws_iam_policy.collie_secrets_policy.arn
}

resource "aws_iam_role" "github_actions_role" {
  name        = "${var.environment}-collie-github-actions"
  description = "Role for GitHub Actions CI/CD pipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.github_oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" = "repo:ScottyLabs/collie:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_policy" "github_actions_ecr_policy" {
  name        = "${var.environment}-collie-github-actions-ecr"
  description = "ECR permissions for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_ecs_policy" {
  name        = "${var.environment}-collie-github-actions-ecs"
  description = "ECS permissions for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_iam_policy" {
  name        = "${var.environment}-collie-github-actions-iam"
  description = "IAM PassRole permissions for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = "arn:aws:iam::${var.account_id}:role/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_ecs_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_ecs_policy.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_iam_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_iam_policy.arn
}