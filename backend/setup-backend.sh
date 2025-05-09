#!/bin/bash

# Exit on error
set -e

# Default variables
BUCKET_NAME="scottylabs-terraform-state"
REGION="us-east-2"
PROFILE="scottylabs-gabriel"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --region)
      REGION="$2"
      shift 2
      ;;
    --bucket)
      BUCKET_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--profile PROFILE] [--region REGION] [--bucket BUCKET_NAME]"
      exit 1
      ;;
  esac
done

PROFILE_ARG="--profile $PROFILE"

echo "Setting up Terraform remote state backend..."
echo "Using AWS Profile: $PROFILE"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if user is authenticated with AWS
if ! aws sts get-caller-identity $PROFILE_ARG &> /dev/null; then
    echo -e "${RED}Error: You are not authenticated with AWS. Please run 'aws configure' or set up your AWS credentials.${NC}"
    exit 1
fi

echo "Creating S3 bucket for Terraform state..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" $PROFILE_ARG 2>/dev/null; then
    echo "Bucket '$BUCKET_NAME' already exists."
else
    aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION" $PROFILE_ARG && \
        echo -e "${GREEN}Created bucket '$BUCKET_NAME'${NC}" || \
        { echo -e "${RED}Failed to create bucket '$BUCKET_NAME'${NC}"; exit 1; }
fi

echo "Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    $PROFILE_ARG && \
echo -e "${GREEN}Enabled versioning on bucket '$BUCKET_NAME'${NC}" || \
{ echo -e "${RED}Failed to enable versioning on bucket '$BUCKET_NAME'${NC}"; exit 1; }

echo "Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
          }
        }
      ]
    }' \
    $PROFILE_ARG && \
echo -e "${GREEN}Enabled encryption on bucket '$BUCKET_NAME'${NC}" || \
{ echo -e "${RED}Failed to enable encryption on bucket '$BUCKET_NAME'${NC}"; exit 1; }

echo -e "${GREEN}Terraform remote state backend setup complete!${NC}"
echo "S3 Bucket: $BUCKET_NAME"
echo "Region: $REGION"
echo "AWS Profile: $PROFILE"
echo ""
echo "Use this configuration in your Terraform files:"
echo ""
echo 'terraform {'
echo '  backend "s3" {'
echo "    bucket       = \"$BUCKET_NAME\""
echo '    key          = "env/app/terraform.tfstate"'
echo "    region       = \"$REGION\""
echo "    use_lockfile = true"
echo "    profile      = \"$PROFILE\""
echo '    encrypt      = true'
echo '  }'
echo '}' 