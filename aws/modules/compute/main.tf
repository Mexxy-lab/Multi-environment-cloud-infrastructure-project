# Resolve the latest AWS-published Amazon Linux 2023 x86_64 AMI.
# This avoids hard-coding a region-specific AMI ID.
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Create a security group with no inbound rules.
# Administrators will use Systems Manager Session Manager instead of SSH.
resource "aws_security_group" "instance" {
  name_prefix = "mctp-${var.environment}-compute-"
  description = "Restrict inbound access; use AWS Systems Manager"
  vpc_id      = var.vpc_id

  # Allow outbound traffic so the SSM agent can contact AWS services.
  # This works because the selected public subnet gets a public IPv4 address.
  egress {
    description = "Allow outbound HTTPS and required service traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Keep resource names unique and associate them with the project.
  tags = {
    Name        = "mctp-${var.environment}-compute-sg"
    Environment = var.environment
  }

  # Avoid replacing the group before a replacement is ready.
  lifecycle {
    create_before_destroy = true
  }
}

# Create an IAM role that EC2 can assume.
# Do not place AWS access keys on the instance.
resource "aws_iam_role" "instance" {
  name = "mctp-${var.environment}-ec2-ssm-role"

  # Only the EC2 service is allowed to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

# Grant the instance the AWS-managed permissions needed by SSM.
# These permissions enable Systems Manager management; they do not grant
# unrestricted administrator access to the AWS account.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach the role to EC2 through an instance profile.
resource "aws_iam_instance_profile" "instance" {
  name = "mctp-${var.environment}-ec2-ssm-profile"
  role = aws_iam_role.instance.name
}

# Launch a small Linux instance for validating the compute layer.
resource "aws_instance" "this" {
  ami           = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type = var.instance_type

  # Use the first public subnet created by the existing network module.
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true

  # Use the instance profile instead of embedded AWS credentials.
  iam_instance_profile = aws_iam_instance_profile.instance.name

  # Require IMDSv2 to reduce exposure to metadata credential theft.
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypt the root disk and delete it when the instance is terminated.
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  # Wait until the SSM role is attached before creating the instance.
  depends_on = [
    aws_iam_role_policy_attachment.ssm
  ]

  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = "multi-cloud-terraform-platform"
    ManagedBy   = "Terraform"
  }
}