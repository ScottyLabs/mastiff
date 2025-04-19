resource "aws_security_group" "grafana" {
  name        = "${var.environment}-${var.project_name}-grafana"
  description = "Security group for Grafana server"
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
      Name = "${var.environment}-${var.project_name}-grafana"
    }
  )
}

resource "aws_security_group_rule" "grafana_ui_ingress" {
  security_group_id        = aws_security_group.grafana.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.grafana_alb.id
  description              = "Allow ingress from ALB to Grafana UI"
}

resource "aws_security_group" "grafana_alb" {
  name        = "${var.environment}-${var.project_name}-grafana-alb"
  description = "Security group for Grafana ALB"
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
      Name = "${var.environment}-${var.project_name}-grafana-alb"
    }
  )
}

resource "aws_security_group" "grafana_efs" {
  name        = "${var.environment}-${var.project_name}-grafana-efs"
  description = "Security group for Grafana EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.grafana.id]
    description     = "Allow NFS traffic from Grafana tasks"
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
      Name = "${var.environment}-${var.project_name}-grafana-efs"
    }
  )
}