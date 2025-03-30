# ScottyLabs Infrastructure

This repository contains the Terraform infrastructure code for ScottyLabs applications.

## Project Structure

```
.
├── environments/            # Environment-specific configurations
│   ├── dev/                 # Development environment
│   ├── staging/             # Staging environment
│   └── prod/                # Production environment
├── modules/                 # Reusable Terraform modules
│   ├── ecs/                 # ECS cluster and service configurations
│   ├── rds/                 # RDS database configurations
│   └── networking/          # VPC, subnets, security groups, etc.
└── backend/                 # Remote state configuration
```

## Environments

Each environment (dev, staging, prod) has its own state file and can be applied independently. Within each environment, you can deploy multiple applications.

## Getting Started

### Prerequisites

- Terraform v1.0.0+
- AWS CLI configured with appropriate credentials
- S3 bucket for remote state storage
- DynamoDB table for state locking

### Usage

To initialize and apply infrastructure for a specific environment (e.g., dev):

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

## Modules

### ECS Module

The ECS module creates an ECS cluster, task definitions, and services for your backend applications.

### RDS Module

The RDS module creates RDS instances and manages database configurations. Databases can be shared across multiple applications if needed.

### Networking Module

The networking module sets up the VPC, subnets, security groups, and other networking resources.

## State Management

This project uses remote state stored in S3 with DynamoDB locking. Each combination of environment and application has its own state file.
