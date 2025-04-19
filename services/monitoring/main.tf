module "prometheus" {
  source = "../../modules/observability/prometheus"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  cluster_arn         = var.cluster_arn
  execution_role_arn  = var.execution_role_arn
  aws_region          = var.aws_region
  
  prometheus_cpu      = 1024  # 1 vCPU
  prometheus_memory   = 2048  # 2 GB
  prometheus_version  = "v2.45.0"
  
  allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_alb        = true
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "grafana" {
  source = "../../modules/observability/grafana"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  cluster_arn         = var.cluster_arn
  execution_role_arn  = var.execution_role_arn
  aws_region          = var.aws_region
  
  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password
  prometheus_url         = module.prometheus.prometheus_url
  
  allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_alb        = true
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "uptime_kuma" {
  source = "../../modules/observability/uptime-kuma"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  cluster_arn         = var.cluster_arn
  execution_role_arn  = var.execution_role_arn
  aws_region          = var.aws_region
  
  uptime_kuma_environment_variables = {
    # Optional env vars for Uptime Kuma
    # See: https://github.com/louislam/uptime-kuma-wiki/blob/master/Environment-Variables.md
    UPTIME_KUMA_HIDE_LOG         = "debug_monitor,info_monitor"
    UPTIME_KUMA_WS_ORIGIN_CHECK  = "bypass" # Only if behind a reverse proxy with different domains
  }
  
  allowed_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  internal_alb        = true
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "opentelemetry" {
  source = "../../modules/observability/opentelemetry"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  cluster_arn         = var.cluster_arn
  execution_role_arn  = var.execution_role_arn
  aws_region          = var.aws_region
  
  prometheus_endpoint = module.prometheus.prometheus_url
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}