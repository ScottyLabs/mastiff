module "vpc" {
  source = "./modules/aws/vpc"

  name = "${var.environment}-${var.project_name}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "ecs" {
  source = "./modules/aws/ecs"

  cluster_name              = "${var.environment}-${var.project_name}-cluster"
  enable_container_insights = true
  execution_role_name       = "${var.environment}-${var.project_name}-ecs-execution-role"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

module "bastion" {
  source = "./modules/aws/ec2"

  name                = "${var.environment}-${var.project_name}-bastion"
  ami_id              = data.aws_ami.amazon_linux_2023.id
  instance_type       = "t3.micro"
  subnet_id           = module.vpc.public_subnet_ids[0]
  vpc_id              = module.vpc.vpc_id
  associate_public_ip = true
  root_volume_size    = 20

  ingress_rules = [
    {
      description = "EC2 Instance Connect"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_bastion_cidr_blocks
    }
  ]

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/EC2InstanceConnect"
  ]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    
    # Ensure EC2 Instance Connect is installed
    dnf install -y ec2-instance-connect
    
    # Configure SSH to allow EC2 Instance Connect
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
    echo "AuthorizedKeysCommand /opt/aws/bin/eic_run_authorized_keys %u %f" >> /etc/ssh/sshd_config
    echo "AuthorizedKeysCommandUser ec2-instance-connect" >> /etc/ssh/sshd_config
    
    # Restart SSH service
    systemctl restart sshd
    
    echo "Bastion host with EC2 Instance Connect setup complete"
  EOF

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
    Name        = "${var.environment}-${var.project_name}-bastion"
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = false
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-2023.7.20250331.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_caller_identity" "current" {}

module "cmumaps" {
  source = "./services/cmumaps"

  environment          = var.environment
  cluster_arn          = module.ecs.cluster_arn
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_cidrs = module.vpc.private_subnet_cidrs

  account_id               = data.aws_caller_identity.current.account_id
  github_oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
}
