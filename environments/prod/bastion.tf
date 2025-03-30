module "bastion" {
  source = "../../modules/ec2"

  name                = "${var.environment}-${var.project_name}-bastion"
  ami_id              = data.aws_ami.amazon_linux_2.id
  instance_type       = "t3.micro"
  subnet_id           = module.networking.public_subnet_ids[0]
  vpc_id              = module.networking.vpc_id
  associate_public_ip = true
  root_volume_size    = 20

  ingress_rules = []

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    echo "Bastion host setup complete"
  EOF

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Terraform   = "true"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
