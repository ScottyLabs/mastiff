resource "aws_iam_role" "prometheus_task_role" {
  name = "${var.environment}-${var.project_name}-prometheus-task-role"

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

resource "aws_iam_policy" "prometheus_service_discovery" {
  name        = "${var.environment}-${var.project_name}-prometheus-sd"
  description = "Allow Prometheus to discover services via EC2 and ECS APIs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Effect   = "Allow",
        Resource = aws_efs_file_system.prometheus_data.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_service_discovery" {
  role       = aws_iam_role.prometheus_task_role.name
  policy_arn = aws_iam_policy.prometheus_service_discovery.arn
}

resource "aws_iam_role_policy_attachment" "prometheus_execution_role" {
  role       = var.execution_role_arn
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}