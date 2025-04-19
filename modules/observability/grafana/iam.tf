resource "aws_iam_role" "grafana_task_role" {
  name = "${var.environment}-${var.project_name}-grafana-task-role"

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

  tags = var.tags
}

resource "aws_iam_policy" "grafana_efs_access" {
  name        = "${var.environment}-${var.project_name}-grafana-efs-access"
  description = "Allow Grafana to access EFS for persistent storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Effect   = "Allow",
        Resource = aws_efs_file_system.grafana_data.arn
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_ssm_access" {
  name        = "${var.environment}-${var.project_name}-grafana-ssm-access"
  description = "Allow Grafana to access SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:parameter/${var.environment}/${var.project_name}/grafana/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "grafana_cloudwatch_access" {
  name        = "${var.environment}-${var.project_name}-grafana-cloudwatch"
  description = "Allow Grafana to access CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_efs_access" {
  role       = aws_iam_role.grafana_task_role.name
  policy_arn = aws_iam_policy.grafana_efs_access.arn
}

resource "aws_iam_role_policy_attachment" "grafana_ssm_access" {
  role       = aws_iam_role.grafana_task_role.name
  policy_arn = aws_iam_policy.grafana_ssm_access.arn
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch_access" {
  role       = aws_iam_role.grafana_task_role.name
  policy_arn = aws_iam_policy.grafana_cloudwatch_access.arn
}