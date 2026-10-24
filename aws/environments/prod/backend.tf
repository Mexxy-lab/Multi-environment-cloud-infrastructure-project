# Store this environment's state in the shared, secured S3 bucket.
# terraform {
#   backend "s3" {
#     bucket       = ""
#     key          = "aws/prod/terraform.tfstate"
#     region       = "us-east-1"

#     # Use S3-native state locking to prevent concurrent state changes.
#     use_lockfile = true
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
