# AWS region in which the remote-state bucket will be created.
variable "aws_region" {
  description = "AWS region for the Terraform state bucket"
  type        = string
  default     = "us-east-1"
}

# Account ID guard: prevents Terraform from managing another account.
variable "aws_account_id" {
  description = "AWS account ID allowed to be managed"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS account ID must contain exactly 12 digits."
  }
}

# S3 bucket names must be globally unique across AWS.
variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state"
  type        = string

  validation {
    condition = (
      length(var.state_bucket_name) >= 3 &&
      length(var.state_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.state_bucket_name))
    )
    error_message = "Use a valid S3 bucket name of 3–63 lowercase letters, digits, dots, or hyphens."
  }
}