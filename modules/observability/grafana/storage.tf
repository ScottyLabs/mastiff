resource "aws_efs_file_system" "grafana_data" {
  creation_token = "${var.environment}-${var.project_name}-grafana-data"
  encrypted      = true
  
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-grafana-data"
    }
  )
}

resource "aws_efs_access_point" "grafana_data" {
  file_system_id = aws_efs_file_system.grafana_data.id
  
  posix_user {
    gid = 472 # grafana user gid
    uid = 472 # grafana user uid
  }
  
  root_directory {
    path = "/grafana"
    creation_info {
      owner_gid   = 472
      owner_uid   = 472
      permissions = "755"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}-grafana-ap"
    }
  )
}

resource "aws_efs_mount_target" "grafana_data" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.grafana_data.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.grafana_efs.id]
}