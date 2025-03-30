# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.app_name
  requires_compatibilities = var.launch_type == "FARGATE" ? ["FARGATE"] : ["EC2"]
  network_mode             = var.launch_type == "FARGATE" ? "awsvpc" : var.network_mode
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode(var.container_definitions)

  dynamic "volume" {
    for_each = var.volumes != null ? var.volumes : {}

    content {
      name      = volume.key
      host_path = volume.value.host_path
    }
  }

  tags = var.tags
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  dynamic "network_configuration" {
    for_each = var.launch_type == "FARGATE" ? [1] : []

    content {
      subnets          = var.subnet_ids
      security_groups  = [aws_security_group.this.id]
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancers != null ? var.load_balancers : []

    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  tags = var.tags
}

# ECR Repository
resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}

# Security Group
resource "aws_security_group" "this" {
  name        = "${var.app_name}-ecs-sg"
  description = "Security group for ${var.app_name} ECS service"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
