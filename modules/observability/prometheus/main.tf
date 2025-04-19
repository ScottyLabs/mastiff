resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.environment}-${var.project_name}-prometheus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.prometheus_cpu
  memory                   = var.prometheus_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.prometheus_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:${var.prometheus_version}"
      essential = true
      
      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]
      
      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        }
      ]
      
      mountPoints = [
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus"
          readOnly      = false
        },
        {
          sourceVolume  = "prometheus-config"
          containerPath = "/etc/prometheus"
          readOnly      = true
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.prometheus.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "prometheus"
        }
      }
      
      linuxParameters = {
        initProcessEnabled = true
      }
      
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--web.console.libraries=/etc/prometheus/console_libraries",
        "--web.console.templates=/etc/prometheus/consoles",
        "--web.enable-lifecycle"
      ]
    }
  ])

  volume {
    name = "prometheus-data"
    
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.prometheus_data.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus_data.id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "prometheus-config"
  }

  ephemeral_storage {
    size_in_gib = 25
  }

  tags = var.tags
}