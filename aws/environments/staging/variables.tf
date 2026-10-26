variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "AWS account ID Terraform is allowed to manage"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS account ID must contain exactly 12 digits."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "CIDR range for the dev VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR ranges"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR ranges"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

# Configure instance size independently for each environment.
variable "instance_type" {
  description = "EC2 instance type for this environment"
  type        = string
  default     = "t3.micro"
}
# Keep compute disabled until an environment explicitly opts in.
# Enable EC2 only when explicitly requested for this environment.
variable "enable_compute" {
  description = "Whether to deploy an EC2 compute instance"
  type        = bool
  default     = false
}

# variable "state_bucket_name" {
#   description = "Globally unique S3 bucket name for Terraform state"
#   type        = string

#   validation {
#     condition = (
#       length(var.state_bucket_name) >= 3 &&
#       length(var.state_bucket_name) <= 63 &&
#       can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.state_bucket_name))
#     )
#     error_message = "Use a valid S3 bucket name of 3–63 lowercase letters, digits, dots, or hyphens."
#   }
# }