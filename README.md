# Multi-Cloud Terraform Platform

A portfolio project demonstrating secure, reusable, and environment-aware infrastructure provisioning across AWS and Microsoft Azure using Terraform.

**Project status:** AWS foundation and environment configurations are implemented; dev compute deployment and validation are in progress. Azure implementation and CI/CD automation remain planned milestones.

## Table of Contents

- [Overview](#overview)
- [Objectives](#objectives)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [AWS Implementation](#aws-implementation)
- [Security Design](#security-design)
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Deploying the AWS Backend](#deploying-the-aws-backend)
- [Deploying Dev Infrastructure](#deploying-dev-infrastructure)
- [Staging and Production](#staging-and-production)
- [Validation and Troubleshooting](#validation-and-troubleshooting)
- [Cost Management](#cost-management)
- [Cleanup and State Protection](#cleanup-and-state-protection)
- [Roadmap](#roadmap)
- [Learning Outcomes](#learning-outcomes)

## Overview

This project builds a reusable Terraform platform for provisioning cloud infrastructure across separate development, staging, and production environments.

The initial implementation targets AWS. The architecture uses reusable Terraform modules, environment-specific configuration, remote state stored in Amazon S3, and native S3 state locking. A corresponding Azure implementation is planned.

The goal is to demonstrate how infrastructure can be defined as code, reviewed before deployment, consistently provisioned, and managed with security and cost controls.

## Objectives

- Build reusable Terraform modules for networking and compute.
- Maintain separate configurations and state for dev, staging, and production.
- Store Terraform state remotely in a secured S3 bucket.
- Enable S3-native state locking with `use_lockfile = true`.
- Enable S3 versioning to support state recovery.
- Apply secure defaults to EC2, IAM, networking, and storage.
- Validate infrastructure through Terraform plans and AWS CLI checks.
- Prepare the repository for automated Terraform validation and deployment.
- Extend the platform to Azure after the AWS foundation is validated.

## Architecture

### AWS network and compute

The current AWS design provisions a dedicated VPC for each environment. Each VPC contains two public subnets and two private subnets distributed across two Availability Zones.

The compute module can deploy a Linux EC2 instance into a public subnet. Inbound security-group rules are intentionally absent, and AWS Systems Manager Session Manager is the preferred administrative access method.

```text
AWS Account — us-east-1
|
+-- Dev VPC: 10.10.0.0/16
|   +-- Public subnet 1: 10.10.1.0/24
|   +-- Public subnet 2: 10.10.2.0/24
|   +-- Private subnet 1: 10.10.11.0/24
|   +-- Private subnet 2: 10.10.12.0/24
|   +-- Optional EC2 compute instance
|
+-- Staging VPC: 10.20.0.0/16
|   +-- Two public subnets
|   +-- Two private subnets
|   +-- Compute disabled by default
|
+-- Production VPC: 10.30.0.0/16
    +-- Two public subnets
    +-- Two private subnets
    +-- Compute disabled by default
```

Each environment has a separate Terraform state key in the shared S3 bucket. The environments are logically isolated by their VPCs and state files; they are not separate AWS accounts.

### Remote state architecture

```text
Terraform configuration
        |
        v
Private S3 state bucket
        |
        +-- Versioning enabled
        +-- Server-side encryption
        +-- Public access blocked
        +-- HTTPS-only bucket policy
        +-- Native state locking
        |
        +-- aws/dev/terraform.tfstate
        +-- aws/staging/terraform.tfstate
        +-- aws/prod/terraform.tfstate
```

The bootstrap configuration creates the bucket. The environment configurations use the bucket as their remote backend. The bootstrap configuration's own state remains local and must be backed up securely.

## Technology Stack

| Technology          | Purpose                                    |
| ------------------- | ------------------------------------------ |
| Terraform           | Infrastructure as code                     |
| AWS provider        | Provision AWS resources                    |
| Amazon VPC          | Network isolation                          |
| Amazon EC2          | Compute                                    |
| Amazon S3           | Remote Terraform state                     |
| AWS IAM             | Workload identity and permissions          |
| AWS Systems Manager | Remote administration                      |
| AWS CLI             | Infrastructure verification                |
| Git and GitHub      | Version control and portfolio presentation |
| Microsoft Azure     | Planned second cloud implementation        |
| GitHub Actions      | Planned CI/CD automation                   |

## AWS Implementation

### Networking module

The reusable networking module creates:

- A VPC with DNS support and DNS hostnames enabled.
- An Internet Gateway.
- Two public subnets across available Availability Zones.
- Two private subnets across available Availability Zones.
- A public route table with an Internet Gateway route.
- A private route table without a default internet route.
- Route table associations for each subnet.

The module accepts environment-specific CIDR ranges and returns the VPC ID, subnet IDs, and Availability Zone information.

Private subnets do not have a NAT Gateway in the current design. Resources placed there will not automatically have outbound internet connectivity.

### Compute module

The compute module is designed to provision:

- An Amazon Linux 2023 EC2 instance.
- A security group with no inbound rules.
- An IAM role for EC2.
- An instance profile.
- The AWS-managed `AmazonSSMManagedInstanceCore` policy.
- An encrypted 8 GiB `gp3` root volume.
- IMDSv2 with token enforcement.
- Consistent project and environment tags.

Compute is opt-in. The intended default is to keep compute disabled in staging and production until explicitly enabled.

The current dev configuration uses a small `t3.micro` instance for initial validation. Instance suitability and costs should be reviewed before using this size in production.

### Remote state and locking

Each environment uses its own backend key and native S3 lockfile:

```hcl
# Example backend configuration for the dev environment.
terraform {
  backend "s3" {
    bucket       = "YOUR-STATE-BUCKET"
    key          = "aws/dev/terraform.tfstate"
    region       = "us-east-1"

    # Prevent concurrent Terraform operations on this state.
    use_lockfile = true
  }
}
```

Replace the bucket placeholder with the actual bucket name created by the bootstrap configuration. The real environment backend files should contain the actual bucket name.

The state bucket uses versioning and server-side encryption, blocks public access, and denies insecure transport. State files can contain sensitive infrastructure metadata, so access must remain restricted to authorized operators and automation roles.

## Security Design

Security controls implemented or intended by the current AWS configuration include:

- **Account guardrails:** The AWS provider uses `allowed_account_ids` to restrict the target account.
- **Remote state protection:** S3 encryption, versioning, public-access blocking, and an HTTPS-only policy.
- **State concurrency:** S3-native locking through `use_lockfile = true`.
- **Restricted instance access:** No inbound security-group rules for the compute instance.
- **Workload identity:** EC2 uses an IAM instance profile rather than embedded AWS access keys.
- **Metadata protection:** IMDSv2 is required.
- **Storage encryption:** The EC2 root volume is encrypted.
- **Environment separation:** Each environment uses different CIDR ranges and a distinct state key.
- **Git hygiene:** Terraform state, saved plans, variable files, and credentials should not be committed.

### Security improvements planned

- Use short-lived AWS credentials or federation rather than long-lived IAM user keys.
- Implement least-privilege policies for deployment and state access.
- Consider private compute with Systems Manager VPC endpoints instead of public IPv4 addresses.
- Add automated security scanning and policy checks.
- Add CI/CD approval gates for production.
- Define a backup and recovery procedure for the bootstrap's local state.

## Prerequisites

Run the project from Ubuntu on WSL or another supported Linux environment.

Install and configure:

- Terraform CLI (the development environment has been tested with Terraform v1.15.8).
- AWS CLI v2.
- Git.
- An AWS account and an identity authorized to create the required infrastructure.
- A configured AWS CLI profile.
- The Session Manager plugin if you want to use `aws ssm start-session`.

Confirm the tools are available:

```bash
# Display the installed tool versions.
terraform version
aws --version
git --version

# Verify the configured AWS identity without exposing credentials.
aws sts get-caller-identity --profile default

# Verify the configured region.
aws configure get region --profile default
```

The examples below use the `default` AWS profile and the `us-east-1` region.

## Initial Setup

Clone the repository or open the existing local working copy:

```bash
# Navigate to the project root.
cd ~/projects/multi-cloud-terraform-platform

# Inspect the current repository state before editing.
git status --short
```

Terraform variable files should be created locally and excluded from version control.

## Deploying the AWS Backend

The bootstrap configuration must be initialized and applied before an environment can use the S3 backend.

```bash
# Enter the separate backend bootstrap configuration.
cd ~/projects/multi-cloud-terraform-platform/aws/bootstrap

# Format and initialize the bootstrap configuration.
terraform fmt -recursive
terraform init

# Check the configuration before planning.
terraform validate

# Save and inspect the proposed bucket configuration.
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan

# Apply only after confirming the account, region, and resources.
terraform apply bootstrap.tfplan

# Display the created backend details.
terraform output
```

The bootstrap uses a local state file for now. Keep a secure backup of that state and do not delete it casually. The bucket's `prevent_destroy` lifecycle safeguard reduces accidental deletion through Terraform but is not a substitute for backup and access controls.

## Deploying Dev Infrastructure

Initialize the dev environment and validate the configuration:

```bash
# Enter the dev environment.
cd ~/projects/multi-cloud-terraform-platform/aws/environments/dev

# Initialize or migrate state to the configured S3 backend.
terraform init -migrate-state

# Format and validate the Terraform configuration.
terraform fmt -recursive
terraform validate

# Generate a saved plan for review.
terraform plan -out=dev.tfplan

# Review the plan before applying any changes.
terraform show dev.tfplan
```

If the backend has already been initialized and no local state migration is needed, a normal `terraform init` is sufficient. If Terraform requests migration of existing state, confirm the destination bucket and key before accepting.

Apply the reviewed plan:

```bash
# Apply the exact saved plan that was reviewed.
terraform apply dev.tfplan

# Display outputs, including compute details when enabled.
terraform output
```

The plan must be regenerated if configuration changes after it was created.

## Staging and Production

Staging and production share the reusable modules but use independent configurations and remote state keys.

Before applying either environment:

1. Review its CIDR ranges, instance size, and compute enablement.
2. Confirm the intended AWS account and region.
3. Generate and inspect a fresh plan.
4. Confirm that no unexpected resource replacements or deletions are proposed.
5. Use an explicit approval step before applying production changes.

Example validation:

```bash
# Validate staging without applying changes.
terraform -chdir=aws/environments/staging init
terraform -chdir=aws/environments/staging validate
terraform -chdir=aws/environments/staging plan

# Validate production without applying changes.
terraform -chdir=aws/environments/prod init
terraform -chdir=aws/environments/prod validate
terraform -chdir=aws/environments/prod plan
```

Keep compute disabled until the environment is intentionally approved for deployment.

## Validation and Troubleshooting

### Terraform validation

```bash
# Format Terraform files and validate each environment.
terraform fmt -recursive

for ENV in dev staging prod; do
  echo "Validating ${ENV}"
  terraform -chdir="aws/environments/${ENV}" validate
done
```

### Check the EC2 instance

```bash
# Retrieve the instance ID from Terraform outputs.
INSTANCE_ID="$(terraform -chdir=aws/environments/dev output -raw compute_instance_id)"

# Confirm the instance state and assigned networking information.
aws ec2 describe-instances \
  --profile default \
  --region us-east-1 \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType,PublicIP:PublicIpAddress}' \
  --output table
```

### Check inbound security rules

```bash
# Retrieve the security group ID from Terraform outputs.
SG_ID="$(terraform -chdir=aws/environments/dev output -raw compute_security_group_id)"

# An empty result confirms there are no inbound security-group rules.
aws ec2 describe-security-group-rules \
  --profile default \
  --region us-east-1 \
  --filters "Name=group-id,Values=${SG_ID}" \
  --query 'SecurityGroupRules[?IsEgress==`false`].[IpProtocol,FromPort,ToPort,CidrIpv4,CidrIpv6]' \
  --output table
```

### Check Systems Manager connectivity

```bash
# Confirm whether the instance has registered and is online in SSM.
aws ssm describe-instance-information \
  --profile default \
  --region us-east-1 \
  --filters "Key=InstanceIds,Values=${INSTANCE_ID}" \
  --query 'InstanceInformationList[].{Instance:InstanceId,PingStatus:PingStatus}' \
  --output table

# Start a remote shell if the instance is online and permissions are available.
aws ssm start-session \
  --profile default \
  --region us-east-1 \
  --target "$INSTANCE_ID"
```

If the instance does not appear in Systems Manager, check the IAM instance profile, SSM agent, public IP assignment, Internet Gateway route, and outbound connectivity. Also verify that the calling identity has the required SSM session permissions.

### Common issues

| Issue                          | Investigation                                                                                                |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| AWS access denied              | Check the selected CLI profile and IAM permissions.                                                          |
| Account ID guard failure       | Confirm `aws sts get-caller-identity` matches the configured account ID.                                     |
| S3 bucket name unavailable     | Choose a globally unique bucket name and update the bootstrap variables before creating the bucket.          |
| Backend initialization failure | Confirm the bucket exists, the region and key are correct, and the caller has S3 state and lock permissions. |
| Terraform state lock           | Check whether another Terraform operation is running before considering lock recovery.                       |
| SSM instance offline           | Verify the instance role, agent status, and network path to SSM endpoints.                                   |
| Unexpected Terraform changes   | Review the complete plan and refresh assumptions before applying.                                            |

Never remove a Terraform lock file manually just to make a deployment proceed. Confirm that no operation is using the state and follow a controlled recovery procedure.

## Cost Management

Cloud resources can incur charges even when they are used only for learning.

The current design intentionally avoids NAT Gateways, but the following may still incur costs:

- EC2 compute while running.
- Public IPv4 addresses.
- EBS volumes and snapshots.
- S3 storage, requests, and retained object versions.
- Data transfer.
- Optional monitoring and logging services.

AWS Budgets and billing alerts can help detect unexpected spending, but budget alerts do not automatically guarantee that spending will stop at a set amount.

Before deploying, review the AWS Pricing Calculator and the actual account's pricing and free-tier eligibility. Do not assume every instance or service is free.

## Cleanup and State Protection

Do not destroy the backend bucket as part of normal environment cleanup. It contains the state used to manage the environments.

For an environment you intentionally want to remove:

```bash
# Enter only the environment approved for cleanup.
cd ~/projects/multi-cloud-terraform-platform/aws/environments/dev

# Review the resources Terraform proposes to destroy.
terraform plan -destroy

# Destroy only after confirming the target and all resources.
# Run this command only when the destruction is intentional.
terraform destroy
```

A destruction plan should be reviewed with the same care as a deployment plan. Production cleanup requires explicit approval and a recovery plan.

After cleanup, verify that the expected resources are gone and that the state bucket and its versions remain intact.

## Roadmap

- [x] Establish the repository and AWS environment structure.
- [x] Create a reusable AWS networking module.
- [x] Configure dev, staging, and production with separate network ranges.
- [x] Configure the secured S3 remote-state bootstrap.
- [x] Configure S3-native state locking and bucket versioning.
- [x] Implement the initial reusable EC2 compute module.
- [x] Apply and validate the dev network and compute resources.
- [x] Confirm Systems Manager access and document validation evidence.
- [x] Review module quality and production safeguards.
- [ ] Implement the Azure networking and compute modules.
- [ ] Configure Azure remote state and environment isolation.
- [ ] Add Terraform CI/CD with formatting, validation, planning, and approvals.
- [ ] Add security scanning, documentation, and architecture diagrams.
- [ ] Capture screenshots and final deployment evidence for the portfolio.

## Learning Outcomes

This project is intended to demonstrate practical experience with:

- Terraform modules, variables, outputs, providers, and state.
- Cloud network segmentation and routing.
- IAM roles and instance profiles.
- EC2 security controls and Systems Manager.
- Encrypted storage and secure remote state.
- Environment isolation and infrastructure change review.
- AWS CLI validation and troubleshooting.
- Cost awareness and infrastructure lifecycle management.
- Multi-cloud architecture and CI/CD planning.

## Portfolio Summary

This project is developing a reusable Terraform platform for AWS and Azure with isolated environments, secure state management, modular networking and compute, and controlled infrastructure deployment.

The AWS implementation is the first milestone. The final portfolio submission will include validated deployment results, architecture diagrams, security checks, cost considerations, and documented evidence from both cloud providers.
