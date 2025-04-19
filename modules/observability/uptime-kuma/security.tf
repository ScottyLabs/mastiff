resource "aws_security_group" "uptime_kuma" {
  name        = "${var.environment}-${var.project_name}-uptime-kuma"
  description = "Security group for Uptime Kuma server"
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
      Name = "${var.environment}-${var.project_name}-uptime-kuma"
    }
  )
}

resource "aws_security_group_rule" "uptime_kuma_ui_ingress" {
  security_group_id        = aws_security_group.uptime_kuma.id
  type                     = "ingress"
  from_port                = var.uptime_kuma_port
  to_port                  = var.uptime_kuma_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.uptime_kuma_alb.id
  description              = "Allow ingress from ALB to Uptime Kuma UI"
}

resource "aws_security_group" "uptime_kuma_alb" {
  name        = "${var.environment}-${var.project_name}-uptime-kuma-alb"
  description = "Security group for Uptime Kuma ALB"
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
      Name = "${var.environment}-${var.project_name}-uptime-kuma-alb"
    }
  )
}

resource "aws_security_group" "uptime_kuma_efs" {
  name        = "${var.environment}-${var.project_name}-uptime-kuma-efs"
  description = "Security group for Uptime Kuma EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.uptime_kuma.id]
    description     = "Allow NFS traffic from Uptime Kuma tasks"
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
      Name = "${var.environment}-${var.project_name}-uptime-kuma-efs"
    }
  )
}