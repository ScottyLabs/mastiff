resource "aws_db_subnet_group" "this" {
  name        = var.subnet_group_name
  description = "Subnet group for ${var.identifier} RDS instance"
  subnet_ids  = var.subnet_ids

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  name        = var.parameter_group_name
  family      = var.parameter_group_family
  description = "Parameter group for ${var.identifier} RDS instance"

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = var.tags
}

resource "aws_security_group" "rds" {
  name        = "${var.identifier}-rds-sg"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    description = "Database port access"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier                    = var.identifier
  engine                        = var.engine
  engine_version                = var.engine_version
  instance_class                = var.instance_class
  allocated_storage             = var.allocated_storage
  storage_type                  = var.storage_type
  storage_encrypted             = var.storage_encrypted
  kms_key_id                    = var.kms_key_id
  db_name                       = var.db_name
  username                      = var.username
  password                      = var.manage_master_user_password ? null : var.password
  manage_master_user_password   = var.manage_master_user_password
  master_user_secret_kms_key_id = var.master_user_secret_kms_key_id
  port                          = var.port
  vpc_security_group_ids        = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : [aws_security_group.rds.id]
  db_subnet_group_name          = aws_db_subnet_group.this.name
  parameter_group_name          = aws_db_parameter_group.this.name
  multi_az                      = var.multi_az
  publicly_accessible           = var.publicly_accessible
  allow_major_version_upgrade   = var.allow_major_version_upgrade
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  apply_immediately             = var.apply_immediately
  maintenance_window            = var.maintenance_window
  backup_window                 = var.backup_window
  backup_retention_period       = var.backup_retention_period
  skip_final_snapshot           = var.skip_final_snapshot
  final_snapshot_identifier     = var.final_snapshot_identifier
  deletion_protection           = var.deletion_protection

  tags = var.tags
}
