# Multi-environment cloud infrastructure with Terraform

```bash
Setting             Dev                                 Staging                             Production
VPC CIDR            10.10.0.0/16                        10.20.0.0/16                        10.30.0.0/16
Public subnets      10.10.1.0/24, 10.10.2.0/24          10.20.1.0/24, 10.20.2.0/24          10.30.1.0/24, 10.30.2.0/24
Private subnets     10.10.11.0/24, 10.10.12.0/24        10.20.11.0/24, 10.20.12.0/24        10.30.11.0/24, 10.30.12.0/24
State key           aws/dev/terraform.tfstate           aws/staging/terraform.tfstate       aws/prod/terraform.tfstate
```

## Script to populate the bootstrapped bucket to backend files for each environment

```bash
for ENV in dev staging prod; do
  cat > "aws/environments/${ENV}/backend.tf" <<EOF
# Store this environment's state in the shared, secured S3 bucket.
terraform {
  backend "s3" {
    bucket       = "${STATE_BUCKET}"
    key          = "aws/${ENV}/terraform.tfstate"
    region       = "us-east-1"

    # Use S3-native state locking to prevent concurrent state changes.
    use_lockfile = true
  }
}
EOF
done
```

## Resolve the AWS account associated with your existing CLI profile

```bash
AWS_ACCOUNT_ID="$(aws sts get-caller-identity \
  --profile default \
  --query Account \
  --output text)" || exit 1
```

## Create ignored variable files for the two new environments staging and prod

```bash
for ENV in staging prod; do
  cat > "aws/environments/${ENV}/terraform.tfvars" <<EOF
# Restrict Terraform to the intended AWS account.
aws_account_id = "${AWS_ACCOUNT_ID}"
EOF
done
```

## Verify the security controls and state isolation

```bash
# Obtain the bucket name from the bootstrap configuration's output.
STATE_BUCKET="$(terraform -chdir=aws/bootstrap output -raw state_bucket_name)" \
  || exit 1

# Confirm versioning is enabled.
aws s3api get-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --profile default

# Confirm server-side encryption is configured.
aws s3api get-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --profile default

# Confirm all S3 public-access blocks are enabled.
aws s3api get-public-access-block \
  --bucket "$STATE_BUCKET" \
  --profile default

# Confirm ownership controls disable object ACLs.
aws s3api get-bucket-ownership-controls \
  --bucket "$STATE_BUCKET" \
  --profile default

# Clear the temporary bucket-name variable.
unset STATE_BUCKET
```

## Generate plans for each environment

```bash
# Check the proposed dev network without creating resources.
terraform -chdir=aws/environments/dev plan

# Check staging separately; its state and CIDRs are independent.
terraform -chdir=aws/environments/staging plan

# Check production separately;
terraform -chdir=aws/environments/prod plan
```
