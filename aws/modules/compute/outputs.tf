# Expose the instance ID for AWS CLI checks and SSM sessions.
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

# Expose the public IP for inventory and troubleshooting.
# There is no inbound security-group rule permitting SSH.
output "public_ip" {
  description = "Public IPv4 address assigned to the instance"
  value       = aws_instance.this.public_ip
}

# Expose the security group ID for security audits.
output "security_group_id" {
  description = "Security group attached to the instance"
  value       = aws_security_group.instance.id
}

# Expose the IAM role name for verification.
output "iam_role_name" {
  description = "IAM role used by the instance for Systems Manager"
  value       = aws_iam_role.instance.name
}