resource "aws_security_group" "otel" {
  name        = "${var.environment}-${var.project_name}-otel"
  description = "Security group for OpenTelemetry Collector"
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
      Name = "${var.environment}-${var.project_name}-otel"
    }
  )
}

# Allow OTLP/gRPC (4317) traffic from within VPC
resource "aws_security_group_rule" "otel_grpc_ingress" {
  security_group_id = aws_security_group.otel.id
  type              = "ingress"
  from_port         = 4317
  to_port           = 4317
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description       = "Allow OTLP/gRPC traffic from VPC"
}

# Allow OTLP/HTTP (4318) traffic from within VPC
resource "aws_security_group_rule" "otel_http_ingress" {
  security_group_id = aws_security_group.otel.id
  type              = "ingress"
  from_port         = 4318
  to_port           = 4318
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description       = "Allow OTLP/HTTP traffic from VPC"
}

# Allow Prometheus metrics endpoint (8889) traffic from within VPC
resource "aws_security_group_rule" "otel_metrics_ingress" {
  security_group_id = aws_security_group.otel.id
  type              = "ingress"
  from_port         = 8889
  to_port           = 8889
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description       = "Allow Prometheus metrics traffic from VPC"
}

# Allow health check (13133) traffic from within VPC
resource "aws_security_group_rule" "otel_health_ingress" {
  security_group_id = aws_security_group.otel.id
  type              = "ingress"
  from_port         = 13133
  to_port           = 13133
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description       = "Allow health check traffic from VPC"
}

# Allow zpages (55679) traffic from within VPC
resource "aws_security_group_rule" "otel_zpages_ingress" {
  security_group_id = aws_security_group.otel.id
  type              = "ingress"
  from_port         = 55679
  to_port           = 55679
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  description       = "Allow zpages traffic from VPC"
}