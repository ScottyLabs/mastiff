# Terraform Remote State Backend

This directory contains instructions and scripts to set up the remote state backend for Terraform.

## Backend Setup

Before you can use Terraform with remote state, you need to create the S3 bucket and DynamoDB table for state storage and locking.

### Using the Setup Script with AWS Profile

The easiest way to set up your backend is using the provided script:

```bash
# Using the default AWS profile
./setup-backend.sh

# Using a specific AWS profile
./setup-backend.sh --profile scottylabs
```

### Manually Creating S3 Bucket and DynamoDB Table

If you prefer to set up the backend manually, you can use the following commands:

1. Create an S3 bucket for storing Terraform state:

```bash
aws s3api create-bucket --bucket scottylabs-terraform-state --region us-east-2 --profile your-profile
```

2. Enable versioning on the S3 bucket:

```bash
aws s3api put-bucket-versioning --bucket scottylabs-terraform-state --versioning-configuration Status=Enabled
```

3. Enable encryption on the S3 bucket:

```bash
aws s3api put-bucket-encryption --bucket scottylabs-terraform-state --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}' --profile your-profile
```

4. Create a DynamoDB table for state locking:

```bash
aws dynamodb create-table \
  --table-name scottylabs-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-2 \
  --profile your-profile
```

## Using the Remote Backend

Once the backend infrastructure is set up, each environment will use the remote state configuration in its `main.tf` file with a unique key for each environment:

```hcl
terraform {
  backend "s3" {
    bucket         = "scottylabs-terraform-state"
    key            = "env/app/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "scottylabs-terraform-locks"
    profile        = "your-profile"  # AWS profile to use
    encrypt        = true
  }
}
```

Replace `env/app` with the specific environment and application, for example:

- `dev/backend-api-1/terraform.tfstate`
- `staging/backend-api-1/terraform.tfstate`
- `prod/backend-api-1/terraform.tfstate`

This allows each environment and application to have its own isolated state.
