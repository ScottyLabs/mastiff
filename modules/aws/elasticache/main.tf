resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "${var.identifier}-param-group"
  family = var.parameter_group_family

  tags = var.tags
}

resource "aws_security_group" "elasticache" {
  name        = "${var.identifier}-elasticache-sg"
  description = "Security group for ElastiCache cluster ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Cache port access"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Allow egress to anywhere - adjust if stricter control is needed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.identifier
  description          = "ElastiCache replication group for ${var.identifier}"
  node_type            = var.instance_type
  engine               = var.engine
  engine_version       = var.engine_version
  port                 = var.port
  parameter_group_name = aws_elasticache_parameter_group.this.name
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [aws_security_group.elasticache.id]

  # Configure for Cluster Mode Disabled (Primary + Replicas)
  automatic_failover_enabled = var.num_cache_nodes > 1
  num_cache_clusters         = var.num_cache_nodes
  # num_node_groups and replicas_per_node_group are not used for cluster mode disabled

  tags = var.tags

  # Consider adding other parameters like:
  # snapshot_retention_limit
  # snapshot_window
  # maintenance_window
  # kms_key_id (for encryption at rest)
  # transit_encryption_enabled (for encryption in transit)
  # auth_token (for Redis AUTH)
}
