module "service" {
  source = "../../modules/aws/ecs/service"

  environment  = var.environment
  service_name = "akita"

  cluster_arn       = var.cluster_arn
  vpc_id            = var.vpc_id
  subnet_ids        = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids

  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
}

module "redis_cache" {
  source = "../../modules/aws/elasticache"

  identifier          = "${var.environment}-akita-redis"
  vpc_id              = var.vpc_id
  subnet_ids          = var.private_subnet_ids   # Use private subnets for cache
  allowed_cidr_blocks = var.private_subnet_cidrs # Allow access from within VPC private subnets
  instance_type       = "cache.t3.small"         # Choose appropriate size
  num_cache_nodes     = 2                        # 1 primary, 1 replica for HA

  tags = {
    Environment = var.environment
    Service     = "akita"
    Terraform   = "true"
  }
}

resource "aws_security_group_rule" "service_to_redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = module.service.task_security_group_id
  security_group_id        = module.redis_cache.security_group_id
  description              = "Allow Akita service to access Redis cache"
}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "akita_config" {
  name        = "/${var.environment}/akita/config"
  description = "Configuration values for Akita application"

  tags = {
    Environment = var.environment
    Service     = "akita"
    Terraform   = "true"
  }
}

resource "aws_secretsmanager_secret_version" "akita_config" {
  secret_id = aws_secretsmanager_secret.akita_config.id
  secret_string = jsonencode({
    SECRET = "placeholder-value",
  })

  lifecycle {
    ignore_changes = [
      secret_string # Prevent Terraform from trying to update the values once set
    ]
  }
}

data "aws_iam_policy_document" "akita_permissions" {
  statement {
    sid = "AllowConfigSecretAccess"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect    = "Allow"
    resources = [aws_secretsmanager_secret.akita_config.arn]
  }

  statement {
    sid = "AllowKMSDecryptForSecrets"
    actions = [
      "kms:Decrypt"
    ]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "akita_policy" {
  name        = "${var.environment}-akita"
  path        = "/"
  description = "Policy for akita"

  policy = data.aws_iam_policy_document.akita_permissions.json
}

resource "aws_iam_role" "github_actions_role" {
  name        = "${var.environment}-akita-github-actions"
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
            "token.actions.githubusercontent.com:sub" = "repo:ScottyLabs/akita:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_policy" "github_actions_ecr_policy" {
  name        = "${var.environment}-akita-github-actions-ecr"
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
        Resource = "*" # Should be restricted in production
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_ecs_policy" {
  name        = "${var.environment}-akita-github-actions-ecs"
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
  name        = "${var.environment}-akita-github-actions-iam"
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
