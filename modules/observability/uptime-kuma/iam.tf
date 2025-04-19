resource "aws_iam_role" "uptime_kuma_task_role" {
  name = "${var.environment}-${var.project_name}-uptime-kuma-task-role"

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

resource "aws_iam_policy" "uptime_kuma_efs_access" {
  name        = "${var.environment}-${var.project_name}-uptime-kuma-efs-access"
  description = "Allow Uptime Kuma to access EFS for persistent storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Effect   = "Allow",
        Resource = aws_efs_file_system.uptime_kuma_data.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "uptime_kuma_efs_access" {
  role       = aws_iam_role.uptime_kuma_task_role.name
  policy_arn = aws_iam_policy.uptime_kuma_efs_access.arn
}