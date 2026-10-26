# Multi-Cloud Terraform CI/CD

## Objective

Automate Terraform validation and controlled deployments for AWS and Azure
across dev, staging, and production environments.

## Architecture

### Continuous Integration

Workflow: `.github/workflows/terraform-ci.yml`

Runs on pull requests and pushes to `main`.

Checks:

- Terraform formatting
- Terraform initialization without a remote backend
- Terraform validation
- TFLint static analysis
- Trivy infrastructure-as-code security scanning
- Gitleaks secret scanning

The CI workflow does not authenticate to AWS or Azure and does not deploy
infrastructure. It can be tested before remote state storage is created.

### Continuous Deployment

Workflow: `.github/workflows/terraform-deploy.yml`

Triggered manually from GitHub Actions.

Supports:

- AWS or Azure
- dev, staging, or production
- Plan-only or plan-and-apply

Deployment requires:

- A working remote state backend
- GitHub OIDC configured with the selected cloud
- Least-privilege cloud permissions
- Correct GitHub Actions variables
- Appropriate GitHub Environment protection rules

## Terraform root layout

Each directory is an independent Terraform root:

- `aws/bootstrap`
- `aws/environments/dev`
- `aws/environments/staging`
- `aws/environments/prod`
- `azure/bootstrap`
- `azure/environments/dev`
- `azure/environments/staging`
- `azure/environments/prod`

## Remote state

AWS uses an S3 backend with native state locking.

Azure uses an Azure Blob Storage backend with Azure AD authentication.

Backend configuration values must be supplied during `terraform init`.
Terraform backend blocks do not support normal Terraform variable interpolation.

The bootstrap roots create the storage resources needed by the environment roots.
Bootstrap resources should be reviewed and deployed separately before enabling
the deployment workflow.

## GitHub configuration

Create GitHub Environments:

- `dev`
- `staging`
- `prod`

Configure required reviewers and deployment restrictions for `prod`.

Configure repository Actions variables:

### AWS

- `AWS_TERRAFORM_ROLE_ARN`
- `AWS_TF_STATE_BUCKET`

### Azure

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TF_STATE_RESOURCE_GROUP`
- `AZURE_TF_STATE_STORAGE_ACCOUNT`
- `AZURE_TF_STATE_CONTAINER`

Use OIDC federated identity instead of long-lived access keys. Scope permissions
to the repository, branch or environment, state storage, and resources that the
Terraform root is authorized to manage.

## Cost controls

CI runs validation and security checks without deploying resources.

The deployment workflow is manual. Start with a plan-only run and review all
proposed changes before applying.

Terraform plan is not a cost estimate. Review cloud pricing and planned resource
sizes before applying changes.

## Operational safeguards

- Protect the main branch with required reviews and CI checks.
- Do not commit credentials, Terraform state, or plan files.
- Preserve and deliberately migrate existing state when changing backends.
- Use least-privilege cloud roles.
- Require approval for production changes.
- Review security findings before introducing exceptions.
