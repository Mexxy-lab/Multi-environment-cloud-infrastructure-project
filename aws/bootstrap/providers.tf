# Restrict the bootstrap configuration to the intended AWS account.
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  # Apply consistent tags to resources managed by this configuration.
  default_tags {
    tags = {
      Project   = "multi-cloud-terraform-platform"
      ManagedBy = "Terraform"
      Purpose   = "Terraform remote state"
    }
  }
}