locals {
  grafana_domain = var.grafana_domain != "" ? var.grafana_domain : aws_lb.grafana.dns_name
  root_url       = "http://${local.grafana_domain}"
}

resource "aws_ssm_parameter" "grafana_config" {
  name        = "/${var.environment}/${var.project_name}/grafana/config"
  description = "Grafana configuration file"
  type        = "String"
  value = templatefile("${path.module}/templates/grafana.ini.tpl", {
    root_url         = local.root_url
    domain           = local.grafana_domain
    admin_user       = var.grafana_admin_user
    admin_password   = var.grafana_admin_password
    anonymous_enabled = "false"
  })

  tags = var.tags
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.environment}-${var.project_name}-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.grafana_cpu
  memory                   = var.grafana_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.grafana_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:${var.grafana_version}"
      essential = true
      
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "GF_INSTALL_PLUGINS",
          value = "grafana-clock-panel,grafana-piechart-panel,grafana-worldmap-panel"
        },
        {
          name  = "GF_SECURITY_ADMIN_USER",
          value = var.grafana_admin_user
        },
        {
          name  = "GF_SECURITY_ADMIN_PASSWORD",
          value = var.grafana_admin_password
        },
        {
          name  = "GF_PATHS_DATA",
          value = "/var/lib/grafana"
        },
        {
          name  = "GF_PATHS_LOGS",
          value = "/var/log/grafana"
        },
        {
          name  = "GF_PATHS_PLUGINS",
          value = "/var/lib/grafana/plugins"
        },
        {
          name  = "GF_PATHS_PROVISIONING",
          value = "/etc/grafana/provisioning"
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "grafana-data"
          containerPath = "/var/lib/grafana"
          readOnly      = false
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
      
      linuxParameters = {
        initProcessEnabled = true
      }
    }
  ])

  volume {
    name = "grafana-data"
    
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.grafana_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.grafana_data.id
        iam             = "ENABLED"
      }
    }
  }

  ephemeral_storage {
    size_in_gib = 25
  }

  tags = var.tags
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.environment}-${var.project_name}-grafana"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = var.grafana_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.grafana.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  tags = var.tags

  depends_on = [
    aws_lb_listener.grafana,
    aws_efs_mount_target.grafana_data
  ]
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.environment}/${var.project_name}/grafana"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_lb" "grafana" {
  name               = "${var.environment}-${var.project_name}-graf"
  internal           = var.internal_alb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.grafana_alb.id]
  subnets            = var.internal_alb ? var.private_subnet_ids : var.public_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-grafana"
    }
  )
}

resource "aws_lb_target_group" "grafana" {
  name        = "${var.environment}-${var.project_name}-graf"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    port                = 3000
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "grafana" {
  load_balancer_arn = aws_lb.grafana.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }

  tags = var.tags
}

# Set up Prometheus data source
resource "aws_ssm_parameter" "grafana_datasource" {
  name        = "/${var.environment}/${var.project_name}/grafana/datasources"
  description = "Grafana data sources configuration"
  type        = "String"
  value = jsonencode({
    apiVersion = 1
    datasources = [
      {
        name      = "Prometheus"
        type      = "prometheus"
        access    = "proxy"
        url       = var.prometheus_url
        isDefault = true
      }
    ]
  })

  tags = var.tags
}