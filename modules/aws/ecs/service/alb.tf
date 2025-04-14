resource "aws_security_group" "alb" {
  name        = "${var.environment}-${var.service_name}-alb"
  description = "Security group for the ALB for ${var.service_name} service"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidr_blocks
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
      Name = "${var.environment}-${var.service_name}-alb-sg"
    }
  )
}

resource "aws_lb" "this" {
  name               = "${var.environment}-${var.service_name}"
  internal           = var.alb_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.alb_enable_deletion_protection

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.service_name}-alb"
    }
  )
}

resource "aws_lb_target_group" "this" {
  name        = "${var.environment}-${var.service_name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
