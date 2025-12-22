# OpenTofu Quick Reference

Quick reference guide for using OpenTofu with Sunbird ED AWS installer.

## Installation

```bash
# Install OpenTofu
curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
sudo ./install-opentofu.sh --install-method standalone
rm install-opentofu.sh

# Verify installation
tofu --version
```

## Basic Commands

### Direct OpenTofu Commands

```bash
# Initialize OpenTofu
tofu init

# Format code
tofu fmt

# Validate configuration
tofu validate

# Plan changes
tofu plan

# Apply changes
tofu apply

# Destroy resources
tofu destroy

# Show state
tofu show

# List resources
tofu state list

# Get outputs
tofu output
```

### With Terragrunt (Recommended)

```bash
# Initialize
terragrunt init

# Plan all modules
terragrunt run-all plan

# Apply all modules
terragrunt run-all apply

# Apply with auto-approve
terragrunt run-all apply --terragrunt-non-interactive

# Destroy all
terragrunt run-all destroy

# Get outputs from all modules
terragrunt run-all output
```

## Environment Setup

```bash
# Navigate to your environment
cd terraform/aws/your-environment

# Source environment variables
source tf.sh

# Verify setup
../../verify-opentofu-setup.sh
```

## Common Operations

### Initial Setup

```bash
# 1. Create backend
./install.sh create_tf_backend
source tf.sh

# 2. Create infrastructure
./install.sh create_tf_resources
```

### Update Infrastructure

```bash
# Update a specific module
cd terraform/aws/your-environment/storage
source ../tf.sh
terragrunt apply

# Update all modules
cd terraform/aws/your-environment
source tf.sh
terragrunt run-all apply
```

### Check Status

```bash
# Plan to see what would change
terragrunt run-all plan

# List all resources
terragrunt run-all state list

# Show specific resource
tofu state show module.storage.aws_s3_bucket.public
```

### Troubleshooting

```bash
# Refresh state
terragrunt refresh

# Force unlock state (use with caution)
terragrunt force-unlock <lock-id>

# Re-initialize
terragrunt init -upgrade

# Clean cache
find . -name ".terragrunt-cache" -type d -exec rm -rf {} +
```

## Environment Variables

```bash
# Force Terragrunt to use OpenTofu
export TERRAGRUNT_TFPATH=tofu

# Set AWS region
export AWS_REGION=ap-south-1

# Set backend bucket
export TERRAFORM_BACKEND_BUCKET=your-bucket-name

# Enable detailed logs
export TF_LOG=DEBUG
export TF_LOG_PATH=./opentofu.log
```

## State Management

```bash
# Backup state
aws s3 cp s3://$TERRAFORM_BACKEND_BUCKET/path/terraform.tfstate ./backup.tfstate

# List state versions
aws s3api list-object-versions \
  --bucket $TERRAFORM_BACKEND_BUCKET \
  --prefix path/terraform.tfstate

# Move resource in state
tofu state mv module.old.resource module.new.resource

# Remove resource from state
tofu state rm module.resource

# Import existing resource
tofu import module.resource resource-id
```

## Working with Modules

```bash
# Plan specific module
cd network
terragrunt plan

# Apply specific module
terragrunt apply

# Destroy specific module
terragrunt destroy

# View module dependencies
terragrunt graph-dependencies
```

## Tips and Tricks

### Speed Up Operations

```bash
# Use parallelism
tofu apply -parallelism=20

# Skip refresh (faster, but use carefully)
tofu plan -refresh=false
```

### Format and Validate

```bash
# Format all .tf files
find . -name "*.tf" -exec tofu fmt {} \;

# Validate all modules
terragrunt run-all validate
```

### Work with Specific Resources

```bash
# Target specific resource
tofu apply -target=module.storage.aws_s3_bucket.public

# Exclude resource from plan
tofu plan -target='!module.storage'
```

### Debug Mode

```bash
# Enable debug output
export TF_LOG=DEBUG
tofu apply

# Debug specific subsystem
export TF_LOG=TRACE
export TF_LOG_CORE=DEBUG
export TF_LOG_PROVIDER=DEBUG
```

## Comparison with Terraform

| Operation | Terraform | OpenTofu |
|-----------|-----------|----------|
| Initialize | `terraform init` | `tofu init` |
| Plan | `terraform plan` | `tofu plan` |
| Apply | `terraform apply` | `tofu apply` |
| Destroy | `terraform destroy` | `tofu destroy` |
| Version | `terraform version` | `tofu version` |

**Note**: Terragrunt commands remain the same - it auto-detects OpenTofu.

## Frequently Used Workflows

### Fresh Installation

```bash
cd terraform/aws/my-env
./install.sh
```

### Update Single Service

```bash
# Edit configuration
vim global-values.yaml

# Re-run output generation
cd output-file
terragrunt apply

# Update Helm charts
cd ../../..
helm upgrade -n sunbird service-name ./helmcharts/service
```

### Disaster Recovery

```bash
# Restore from S3 backup
aws s3 cp s3://$TERRAFORM_BACKEND_BUCKET/backup/terraform.tfstate ./terraform.tfstate

# Re-apply infrastructure
terragrunt run-all apply
```

### Migration from Terraform

```bash
# Install OpenTofu (Terraform can coexist)
curl -fsSL https://get.opentofu.org/install-opentofu.sh | sudo bash

# Test with existing state
tofu init
tofu plan  # Should show no changes

# Switch Terragrunt to OpenTofu
export TERRAGRUNT_TFPATH=tofu

# Continue normal operations
terragrunt run-all plan
```

## Getting Help

```bash
# OpenTofu help
tofu --help
tofu apply --help

# Terragrunt help
terragrunt --help

# Verify setup
./verify-opentofu-setup.sh

# View migration guide
cat OPENTOFU_MIGRATION.md

# View detailed changes
cat CHANGES.md
```

## Common Errors and Solutions

### Error: State locked

```bash
# Check who has the lock
aws dynamodb scan --table-name terraform-state-lock

# Force unlock (only if sure no one else is using it)
terragrunt force-unlock <lock-id>
```

### Error: Module not found

```bash
# Re-initialize
terragrunt init -upgrade

# Clear cache
rm -rf .terragrunt-cache
terragrunt init
```

### Error: Provider version conflict

```bash
# Upgrade providers
tofu init -upgrade

# Or lock to specific version in versions.tf
```

### Error: AWS credentials

```bash
# Verify credentials
aws sts get-caller-identity

# Re-configure if needed
aws configure
```

## Quick Links

- **Main README**: [README.md](README.md)
- **Migration Guide**: [OPENTOFU_MIGRATION.md](OPENTOFU_MIGRATION.md)
- **Change Log**: [CHANGES.md](CHANGES.md)
- **OpenTofu Docs**: https://opentofu.org/docs
- **Terragrunt Docs**: https://terragrunt.gruntwork.io

---
**Last Updated**: 2025-12-17
