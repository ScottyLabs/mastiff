provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "scottylabs-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "scottylabs-terraform-locks"
    encrypt        = true
    profile        = "scottylabs-gabriel"
  }
}

module "networking" {
  source = "../../modules/networking"

  name = "${var.environment}-${var.project_name}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "rds" {
  source = "../../modules/rds"

  identifier             = "${var.environment}-${var.project_name}"
  subnet_group_name      = "${var.environment}-${var.project_name}-db-subnet-group"
  subnet_ids             = module.networking.private_subnet_ids
  parameter_group_name   = "${var.environment}-${var.project_name}-db-parameter-group"
  parameter_group_family = "postgres17"

  engine                      = "postgres"
  engine_version              = "17.4"
  instance_class              = "db.t3.medium"
  allocated_storage           = 50
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = var.database_name
  manage_master_user_password = true
  port                        = 5432
  vpc_id                      = module.networking.vpc_id
  allowed_cidr_blocks         = module.networking.private_subnet_cidrs
  vpc_security_group_ids      = []
  multi_az                    = true
  publicly_accessible         = false
  backup_retention_period     = 30
  deletion_protection         = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name              = "${var.environment}-${var.project_name}-cluster"
  enable_container_insights = true
  execution_role_name       = "${var.environment}-${var.project_name}-ecs-execution-role"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}
