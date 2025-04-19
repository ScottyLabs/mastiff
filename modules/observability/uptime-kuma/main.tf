locals {
  container_environment = [
    for name, value in var.uptime_kuma_environment_variables : {
      name  = name
      value = value
    }
  ]
}

resource "aws_ecs_task_definition" "uptime_kuma" {
  family                   = "${var.environment}-${var.project_name}-uptime-kuma"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.uptime_kuma_cpu
  memory                   = var.uptime_kuma_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.uptime_kuma_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "uptime-kuma"
      image     = "louislam/uptime-kuma:${var.uptime_kuma_version}"
      essential = true
      
      portMappings = [
        {
          containerPort = var.uptime_kuma_port
          hostPort      = var.uptime_kuma_port
          protocol      = "tcp"
        }
      ]
      
      environment = local.container_environment

      mountPoints = [
        {
          sourceVolume  = "uptime-kuma-data"
          containerPath = "/app/data"
          readOnly      = false
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.uptime_kuma.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "uptime-kuma"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "wget --spider -q http://localhost:${var.uptime_kuma_port} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  volume {
    name = "uptime-kuma-data"
    
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.uptime_kuma_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.uptime_kuma_data.id
        iam             = "ENABLED"
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_service" "uptime_kuma" {
  name            = "${var.environment}-${var.project_name}-uptime-kuma"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.uptime_kuma.arn
  desired_count   = var.uptime_kuma_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.uptime_kuma.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.uptime_kuma.arn
    container_name   = "uptime-kuma"
    container_port   = var.uptime_kuma_port
  }

  tags = var.tags

  depends_on = [
    aws_lb_listener.uptime_kuma,
    aws_efs_mount_target.uptime_kuma_data
  ]
}

resource "aws_cloudwatch_log_group" "uptime_kuma" {
  name              = "/ecs/${var.environment}/${var.project_name}/uptime-kuma"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_lb" "uptime_kuma" {
  name               = "${var.environment}-${var.project_name}-kuma"
  internal           = var.internal_alb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.uptime_kuma_alb.id]
  subnets            = var.internal_alb ? var.private_subnet_ids : var.public_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-uptime-kuma"
    }
  )
}

resource "aws_lb_target_group" "uptime_kuma" {
  name        = "${var.environment}-${var.project_name}-kuma"
  port        = var.uptime_kuma_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    port                = var.uptime_kuma_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = var.tags
}

resource "aws_lb_listener" "uptime_kuma" {
  load_balancer_arn = aws_lb.uptime_kuma.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uptime_kuma.arn
  }

  tags = var.tags
}