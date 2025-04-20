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

## AWS Stuff

Set up AWS CLI with sso authorization via the following command:

```
aws configure sso
```

SSO session name: `scottylabs`
SSO start URL: `https://scottylabs.awsapps.com/start`
AWS region: `us-east-2`
SSO registration scopes: No need to enter anything.

Then, the CLI will prompt you to open a browser to complete the login process.

Return to the CLI, select `scottylabs` and click `Continue`.

CLI default client Region: `us-east-2`
CLI default output format: `json`
CLI profile name: `scottylabs`

Log into AWS CLI with sso authorization via the following command:

```
aws sso login --profile scottylabs
```

The bastion is a private ec2 instance that has internal VPC access. To access it, a valid sso profile is needed.

```bash
 aws ssm start-session --target <instance id> --profile <sso profile>   
```

### Accessing the RDS Database

Once you've connected to the bastion host via SSM (as described above), you can access the RDS database using the
following steps:

```bash
# Connect to PostgreSQL database
psql -h <rds-endpoint> -U <database-username> -d <database-name>
```

You'll be prompted for the database password. Retrieve it from the secrets manager. Enter it to connect to the database.

For example:

```bash
psql -h scottylabs.cluster-xyz123.us-east-1.rds.amazonaws.com -U postgres -d scottylabs
```

## Managing the Public Schema

### Checking the Current Schema Owner

To check the current owner of the public schema:

```sql
SELECT schema_name, schema_owner
FROM information_schema.schemata
WHERE schema_name = 'public';
```

### Recreating the Public Schema

If you need to recreate the public schema while preserving ownership:

1. First, note the current owner:

```sql
SELECT schema_owner
FROM information_schema.schemata
WHERE schema_name = 'public';
```

2. Drop the schema (with CASCADE if you want to remove all objects within it):

```sql
DROP SCHEMA public CASCADE;
```

3. Recreate the schema:

```sql
CREATE SCHEMA public;
```

4. Set the ownership to the previous owner:

```sql
ALTER SCHEMA public OWNER TO <previous_owner>;
```

5. Restore default privileges:

```sql
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
```

Make sure to back up any important data before dropping the schema if you're doing this in a production environment.
