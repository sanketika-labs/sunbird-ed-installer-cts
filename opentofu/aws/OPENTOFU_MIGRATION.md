# OpenTofu Migration Guide

This document describes the migration from Terraform to OpenTofu for the Sunbird ED AWS installer.

## What is OpenTofu?

OpenTofu is an open-source fork of Terraform, maintained by the Linux Foundation. It was created in response to HashiCorp's license change from Mozilla Public License (MPL) to Business Source License (BSL). OpenTofu maintains full backward compatibility with Terraform 1.6.x and uses the same HashiCorp Configuration Language (HCL) syntax.

## Why OpenTofu?

- **Open Source**: Licensed under MPL 2.0, ensuring it remains truly open-source
- **Community-Driven**: Managed by the Linux Foundation with transparent governance
- **Fully Compatible**: Drop-in replacement for Terraform 1.6.x
- **Same Syntax**: All `.tf` and `.hcl` files work without modification
- **Same Providers**: Uses the same provider registry as Terraform
- **No Vendor Lock-in**: Ensures long-term sustainability and community control

## What Changed?

### 1. Installation Instructions

The README now includes OpenTofu installation instructions instead of Terraform:

```bash
# Install OpenTofu
curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
sudo ./install-opentofu.sh --install-method standalone
rm install-opentofu.sh

# Verify installation
tofu --version
```

### 2. Version Requirements

Updated minimum version requirement in `modules/eks/versions.tf`:
- Old: `required_version = ">= 1.3"`
- New: `required_version = ">= 1.6.0"`

This ensures compatibility with both OpenTofu 1.6.0+ and Terraform 1.6.0+.

### 3. Documentation Updates

All references to "Terraform" in documentation have been updated to "OpenTofu":
- Backend setup descriptions
- Troubleshooting sections
- Installation steps
- State management references

### 4. Script Updates

- `create_tf_backend.sh`: Updated messages to reference "OpenTofu" instead of "Terraform"
- `install.sh`: Updated backend creation messages
- Resource tags: Changed from `ManagedBy=Terraform` to `ManagedBy=OpenTofu`

## What Stayed the Same?

### Configuration Files

All `.tf` and `.hcl` files remain **100% unchanged** in their syntax:

- ✅ All module definitions
- ✅ Resource declarations
- ✅ Provider configurations
- ✅ Variable definitions
- ✅ Output definitions
- ✅ Terragrunt configurations

OpenTofu uses the exact same HCL syntax as Terraform, so no code changes are needed.

### Provider Registry

OpenTofu uses the same provider registry as Terraform:
- `registry.terraform.io/hashicorp/aws`
- `registry.terraform.io/hashicorp/kubernetes`
- All existing providers work without modification

### State Format

OpenTofu and Terraform use the same state file format. This means:
- ✅ Existing Terraform state files work with OpenTofu
- ✅ You can migrate existing infrastructure without rebuilding
- ✅ State is stored in the same S3 backend with the same format

### Terragrunt Compatibility

Terragrunt (version 0.48.0+) natively supports OpenTofu. The configuration remains identical:

```hcl
terraform {
  source = "../../modules/storage"
}
```

This `terraform` block name is maintained for backward compatibility, but Terragrunt will use OpenTofu when it's installed.

## Using OpenTofu

### Command Equivalence

OpenTofu provides the `tofu` command as a drop-in replacement for `terraform`:

| Terraform Command | OpenTofu Command |
|-------------------|------------------|
| `terraform init` | `tofu init` |
| `terraform plan` | `tofu plan` |
| `terraform apply` | `tofu apply` |
| `terraform destroy` | `tofu destroy` |
| `terraform output` | `tofu output` |

### With Terragrunt

Terragrunt automatically detects and uses OpenTofu when installed:

```bash
# Terragrunt will use 'tofu' instead of 'terraform'
terragrunt init
terragrunt plan
terragrunt apply
terragrunt run-all apply
```

To force Terragrunt to use OpenTofu, you can set:

```bash
export TERRAGRUNT_TFPATH=tofu
```

## Migration from Existing Terraform Installation

If you have an existing Terraform-based installation, you can migrate to OpenTofu:

### Step 1: Install OpenTofu

```bash
curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
sudo ./install-opentofu.sh --install-method standalone
rm install-opentofu.sh
```

### Step 2: Verify Compatibility

```bash
tofu --version  # Should show 1.6.0 or higher
```

### Step 3: Test with Existing State

Navigate to your environment directory and test:

```bash
cd opentofu/aws/your-environment
source tf.sh

# OpenTofu can read your existing Terraform state
tofu init
tofu plan
```

The state file in S3 will work seamlessly with OpenTofu.

### Step 4: Continue with Terragrunt

```bash
# Terragrunt will automatically use OpenTofu
terragrunt init
terragrunt plan
```

### Optional: Remove Terraform

Once you've verified OpenTofu works:

```bash
# You can remove Terraform if desired
sudo rm /usr/local/bin/terraform
```

## Backward Compatibility

### Running with Terraform

If you prefer to continue using Terraform instead of OpenTofu, everything will still work:

1. All `.tf` files are compatible with both Terraform 1.6+ and OpenTofu 1.6+
2. The version constraint `>= 1.6.0` allows both tools
3. Terragrunt works with both tools

To use Terraform explicitly with Terragrunt:

```bash
export TERRAGRUNT_TFPATH=terraform
```

### Mixed Environments

You can even use different tools in different environments:
- Team A uses Terraform 1.6.0
- Team B uses OpenTofu 1.6.0
- Both can work with the same state files and configurations

## Verification

After migration, verify everything works:

```bash
# Check OpenTofu installation
tofu version

# Check Terragrunt can find OpenTofu
terragrunt --version
which tofu

# Test initialization
cd opentofu/aws/template
source tf.sh
terragrunt init

# Verify state access
terragrunt run-all plan
```

## Troubleshooting

### Terragrunt Still Using Terraform

If Terragrunt continues using Terraform after installing OpenTofu:

```bash
# Explicitly set the path
export TERRAGRUNT_TFPATH=tofu

# Or remove Terraform
sudo rm $(which terraform)
```

### Version Mismatch Errors

If you see version errors:

```bash
# Check both versions
terraform --version  # If still installed
tofu --version

# Ensure OpenTofu is 1.6.0+
```

### State Lock Issues

If you encounter state locking issues:

```bash
# Force unlock if needed (use with caution)
tofu force-unlock <lock-id>

# Or with Terragrunt
terragrunt force-unlock <lock-id>
```

## Additional Resources

- OpenTofu Official Website: https://opentofu.org
- OpenTofu Documentation: https://opentofu.org/docs
- OpenTofu GitHub: https://github.com/opentofu/opentofu
- Terragrunt OpenTofu Support: https://terragrunt.gruntwork.io/docs/features/opentofu-support/

## Support

For issues specific to this installer:
- Check the main [README.md](README.md)
- Review [troubleshooting section](README.md#troubleshooting)
- Open an issue on GitHub

For OpenTofu-specific issues:
- OpenTofu Community Forum: https://discuss.opentofu.org
- OpenTofu GitHub Issues: https://github.com/opentofu/opentofu/issues
