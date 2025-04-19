resource "aws_security_group" "prometheus" {
  name        = "${var.environment}-${var.project_name}-prometheus"
  description = "Security group for Prometheus server"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-prometheus"
    }
  )
}

resource "aws_security_group_rule" "prometheus_ui_ingress" {
  security_group_id        = aws_security_group.prometheus.id
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.prometheus_alb.id
  description              = "Allow ingress from ALB to Prometheus UI"
}

resource "aws_security_group" "prometheus_alb" {
  name        = "${var.environment}-${var.project_name}-prometheus-alb"
  description = "Security group for Prometheus ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow HTTP from allowed CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-prometheus-alb"
    }
  )
}

resource "aws_security_group" "prometheus_efs" {
  name        = "${var.environment}-${var.project_name}-prometheus-efs"
  description = "Security group for Prometheus EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.prometheus.id]
    description     = "Allow NFS traffic from Prometheus tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-prometheus-efs"
    }
  )
}