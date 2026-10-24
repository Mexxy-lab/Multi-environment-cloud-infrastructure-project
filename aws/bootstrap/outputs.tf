# Expose the bucket name for configuring each environment's backend.
output "state_bucket_name" {
  description = "S3 bucket used for remote Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

# Expose the bucket ARN for IAM policies and security reviews.
output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

# Confirm the region where state will be stored.
output "state_bucket_region" {
  description = "AWS region containing the state bucket"
  value       = var.aws_region
}