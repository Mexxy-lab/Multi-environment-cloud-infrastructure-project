# Environment name used for resource tags.
variable "environment" {
  description = "Environment where the instance will run"
  type        = string
}

# Place the instance in the selected public subnet for outbound SSM access.
variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

# The VPC ID is used to attach the instance security group.
variable "vpc_id" {
  description = "VPC ID for the EC2 security group"
  type        = string
}

# Keep the initial instance small; actual pricing depends on your account.
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Give each environment's instance a predictable name.
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}