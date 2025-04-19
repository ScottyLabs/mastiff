resource "aws_efs_file_system" "uptime_kuma_data" {
  creation_token = "${var.environment}-${var.project_name}-uptime-kuma-data"
  encrypted      = true
  
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-uptime-kuma-data"
    }
  )
}

resource "aws_efs_access_point" "uptime_kuma_data" {
  file_system_id = aws_efs_file_system.uptime_kuma_data.id
  
  posix_user {
    gid = 1000
    uid = 1000
  }
  
  root_directory {
    path = "/app/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-uptime-kuma-ap"
    }
  )
}

resource "aws_efs_mount_target" "uptime_kuma_data" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.uptime_kuma_data.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.uptime_kuma_efs.id]
}