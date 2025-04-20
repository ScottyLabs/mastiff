resource "aws_ssm_parameter" "otel_config" {
  name        = "/${var.environment}/${var.project_name}/otel/config"
  description = "OpenTelemetry Collector configuration"
  type        = "String"
  value = templatefile("${path.module}/templates/collector.yaml.tpl", {
    service_namespace  = "${var.project_name}"
    environment        = var.environment
    prometheus_endpoint = var.prometheus_endpoint
  })

  tags = var.tags
}

resource "aws_ecs_task_definition" "otel" {
  family                   = "${var.environment}-${var.project_name}-otel"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.otel_cpu
  memory                   = var.otel_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.otel_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "otel-collector"
      image     = "${var.otel_image}:${var.otel_version}"
      essential = true
      
      portMappings = [
        {
          containerPort = 4317
          hostPort      = 4317
          protocol      = "tcp"
        },
        {
          containerPort = 4318
          hostPort      = 4318
          protocol      = "tcp"
        },
        {
          containerPort = 8889
          hostPort      = 8889
          protocol      = "tcp"
        },
        {
          containerPort = 13133
          hostPort      = 13133
          protocol      = "tcp"
        },
        {
          containerPort = 55679
          hostPort      = 55679
          protocol      = "tcp"
        }
      ]
      
      secrets = [
        {
          name      = "OTEL_CONFIG",
          valueFrom = aws_ssm_parameter.otel_config.arn
        }
      ]
      
      environment = [
        {
          name  = "AWS_REGION",
          value = var.aws_region
        }
      ]
      
      command = [
        "--config=/etc/otel/config.yaml"
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.otel.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "otel"
        }
      }
      
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:13133/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }
      
      mountPoints = [
        {
          sourceVolume  = "otel-config",
          containerPath = "/etc/otel"
          readOnly      = false
        }
      ]
    }
  ])

  volume {
    name = "otel-config"
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "otel" {
  name              = "/ecs/${var.environment}/${var.project_name}/otel"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_ecs_service" "otel" {
  name            = "${var.environment}-${var.project_name}-otel"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.otel.arn
  desired_count   = var.otel_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.otel.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  tags = var.tags
}

resource "aws_service_discovery_service" "otel" {
  name = "otel-collector"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.otel.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_private_dns_namespace" "otel" {
  name        = "${var.environment}-${var.project_name}-otel.local"
  description = "OpenTelemetry Service Discovery Namespace"
  vpc         = var.vpc_id
}