resource "aws_efs_file_system" "prometheus_data" {
  creation_token = "${var.environment}-${var.project_name}-prometheus-data"
  encrypted      = true
  
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-prometheus-data"
    }
  )
}

resource "aws_efs_access_point" "prometheus_data" {
  file_system_id = aws_efs_file_system.prometheus_data.id
  
  posix_user {
    gid = 65534 # nobody
    uid = 65534 # nobody
  }
  
  root_directory {
    path = "/prometheus"
    creation_info {
      owner_gid   = 65534
      owner_uid   = 65534
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-prometheus-ap"
    }
  )
}

resource "aws_efs_mount_target" "prometheus_data" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.prometheus_data.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.prometheus_efs.id]
}