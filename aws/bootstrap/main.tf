# Create the dedicated S3 bucket that will hold environment state files.
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent an accidental Terraform destroy from deleting the state bucket.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = var.state_bucket_name
  }
}

# Preserve previous versions of state objects for recovery.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt new state and lock objects at rest using S3-managed encryption.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public ACLs and public bucket policies.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Ensure the bucket owns uploaded objects without legacy object ACLs.
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Reject requests that do not use HTTPS, including state and lock access.
resource "aws_s3_bucket_policy" "require_tls" {
  bucket = aws_s3_bucket.terraform_state.id

  # Wait until public-access protections are configured.
  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]

  # This policy denies insecure transport; it does not grant access.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}