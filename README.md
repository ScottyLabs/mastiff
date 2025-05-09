# ScottyLabs Infrastructure

This repository contains the Terraform infrastructure for ScottyLabs applications.

## Environments

Each environment (dev, staging, prod) has its own state file and can be applied independently. Within each environment, you can deploy multiple applications.

## Installation

On macOS, use the following commands to install Terraform:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

> [!CAUTION]
> Do not use `brew install terraform`.

For complete instructions, see the [installation page](https://developer.hashicorp.com/terraform/install).

## Usage

To initialize and apply infrastructure for a specific environment (e.g., prod):

```bash
terraform init -var-file=environments/prod/terraform.tfvars
terraform plan -var-file=environments/prod/terraform.tfvars
terraform apply -var-file=environments/prod/terraform.tfvars
```
