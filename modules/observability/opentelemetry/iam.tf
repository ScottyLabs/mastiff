resource "aws_iam_role" "otel_task_role" {
  name = "${var.environment}-${var.project_name}-otel-task-role"

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

resource "aws_iam_policy" "otel_ecs_discovery" {
  name        = "${var.environment}-${var.project_name}-otel-ecs-discovery"
  description = "Allow OpenTelemetry Collector to discover ECS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeClusters"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ec2:DescribeInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "otel_cloudwatch" {
  name        = "${var.environment}-${var.project_name}-otel-cloudwatch"
  description = "Allow OpenTelemetry Collector to write to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "otel_ssm" {
  name        = "${var.environment}-${var.project_name}-otel-ssm"
  description = "Allow OpenTelemetry Collector to access SSM parameters"

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
          "arn:aws:ssm:${var.aws_region}:*:parameter/${var.environment}/${var.project_name}/otel/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "otel_ecs_discovery" {
  role       = aws_iam_role.otel_task_role.name
  policy_arn = aws_iam_policy.otel_ecs_discovery.arn
}

resource "aws_iam_role_policy_attachment" "otel_cloudwatch" {
  role       = aws_iam_role.otel_task_role.name
  policy_arn = aws_iam_policy.otel_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "otel_ssm" {
  role       = aws_iam_role.otel_task_role.name
  policy_arn = aws_iam_policy.otel_ssm.arn
}