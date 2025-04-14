module "service" {
  source = "../../modules/aws/ecs/service"

  environment  = var.environment
  service_name = "cmumaps"

  cluster_arn       = var.cluster_arn
  vpc_id            = var.vpc_id
  subnet_ids        = var.private_subnet_ids
  public_subnet_ids = var.public_subnet_ids

  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 300
}

module "rds" {
  source = "../../modules/aws/rds"

  identifier             = "${var.environment}-cmumaps-db"
  subnet_group_name      = "${var.environment}-cmumaps-db-subnet-group"
  subnet_ids             = var.private_subnet_ids
  parameter_group_name   = "${var.environment}-cmumaps-db-parameter-group"
  parameter_group_family = "postgres17"

  engine                      = "postgres"
  engine_version              = "17.4"
  instance_class              = "db.t3.medium"
  allocated_storage           = 50
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = "cmumaps"
  manage_master_user_password = true
  port                        = 5432
  vpc_id                      = var.vpc_id
  allowed_cidr_blocks         = var.private_subnet_cidrs
  vpc_security_group_ids      = []
  multi_az                    = true
  publicly_accessible         = false
  backup_retention_period     = 30
  deletion_protection         = true

  skip_final_snapshot = true

  tags = {
    Environment = var.environment
    Service     = "cmumaps"
    Terraform   = "true"
  }
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "cmumaps_db_secret" {
  statement {
    sid = ""
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect    = "Allow"
    resources = [module.rds.db_credentials_secret_arn]
  }

  statement {
    sid = ""
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

resource "aws_secretsmanager_secret" "cmumaps_config" {
  name        = "/${var.environment}/cmumaps/config"
  description = "Configuration values for CMU Maps application"

  tags = {
    Environment = var.environment
    Service     = "cmumaps"
    Terraform   = "true"
  }
}

resource "aws_secretsmanager_secret_version" "cmumaps_config" {
  secret_id = aws_secretsmanager_secret.cmumaps_config.id
  secret_string = jsonencode({
    CLERK_SECRET = "placeholder-value",
    API_KEY      = "placeholder-value"
  })

  lifecycle {
    ignore_changes = [
      secret_string # Prevent Terraform from trying to update the values once set
    ]
  }
}

data "aws_iam_policy_document" "cmumaps_permissions" {
  source_policy_documents = [
    data.aws_iam_policy_document.cmumaps_db_secret.json
  ]

  statement {
    sid = "AllowConfigSecretAccess"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect    = "Allow"
    resources = [aws_secretsmanager_secret.cmumaps_config.arn]
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

resource "aws_iam_policy" "cmumaps_policy" {
  name        = "${var.environment}-cmumaps"
  path        = "/"
  description = "Policy for cmumaps"

  policy = data.aws_iam_policy_document.cmumaps_permissions.json
}

resource "aws_iam_role" "github_actions_role" {
  name        = "${var.environment}-cmumaps-github-actions"
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
            "token.actions.githubusercontent.com:sub" = "repo:ScottyLabs/cmumaps:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  max_session_duration = 3600 # 1 hour
}

resource "aws_iam_policy" "github_actions_ecr_policy" {
  name        = "${var.environment}-cmumaps-github-actions-ecr"
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
  name        = "${var.environment}-cmumaps-github-actions-ecs"
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
  name        = "${var.environment}-cmumaps-github-actions-iam"
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
