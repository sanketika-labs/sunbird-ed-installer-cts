#!/bin/bash
# OpenTofu Setup Verification Script
# This script verifies that all required tools are properly installed for OpenTofu

set -euo pipefail

echo "======================================"
echo "OpenTofu Setup Verification"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ALL_CHECKS_PASSED=true

# Function to check command existence and version
check_command() {
    local cmd=$1
    local min_version=$2
    local version_flag=${3:---version}
    
    if command -v "$cmd" &> /dev/null; then
        version_output=$($cmd $version_flag 2>&1 || true)
        echo -e "${GREEN}✓${NC} $cmd is installed"
        echo "  Version: $version_output" | head -1
        return 0
    else
        echo -e "${RED}✗${NC} $cmd is NOT installed"
        ALL_CHECKS_PASSED=false
        return 1
    fi
}

echo "Checking required tools..."
echo ""

# Check OpenTofu
echo "1. OpenTofu (Infrastructure as Code)"
if check_command "tofu" "1.6.0" "version"; then
    :
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  curl -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh"
    echo "  chmod +x install-opentofu.sh"
    echo "  sudo ./install-opentofu.sh --install-method standalone"
    echo "  rm install-opentofu.sh"
fi
echo ""

# Check Terragrunt
echo "2. Terragrunt (Workflow tool)"
if check_command "terragrunt" "0.45.0" "--version"; then
    terragrunt_version=$(terragrunt --version 2>&1 | head -1 | grep -oP 'v\d+\.\d+\.\d+' || echo "unknown")
    
    # Check if Terragrunt version is 0.48.0+ (native OpenTofu support)
    if [[ "$terragrunt_version" != "unknown" ]]; then
        major=$(echo "$terragrunt_version" | cut -d'v' -f2 | cut -d'.' -f1)
        minor=$(echo "$terragrunt_version" | cut -d'.' -f2)
        
        if [[ $major -eq 0 && $minor -ge 48 ]] || [[ $major -gt 0 ]]; then
            echo -e "${GREEN}  ✓ Terragrunt has native OpenTofu support${NC}"
        else
            echo -e "${RED}  ✗ Terragrunt version is below 0.48.0 - DOES NOT SUPPORT OPENTOFU!${NC}"
            echo -e "${YELLOW}  Current version: $terragrunt_version${NC}"
            echo -e "${YELLOW}  Required: v0.48.0 or higher${NC}"
            echo "  Upgrade with:"
            echo "  wget https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64"
            echo "  chmod +x terragrunt_linux_amd64"
            echo "  sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt"
            ALL_CHECKS_PASSED=false
        fi
    fi
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  wget https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64"
    echo "  chmod +x terragrunt_linux_amd64"
    echo "  sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt"
fi
echo ""

# Check AWS CLI
echo "3. AWS CLI (Cloud provider)"
if check_command "aws" "2.0" "--version"; then
    # Check AWS credentials
    if aws sts get-caller-identity &> /dev/null; then
        echo -e "${GREEN}  ✓ AWS credentials are configured${NC}"
        account_id=$(aws sts get-caller-identity --query Account --output text)
        echo "  Account ID: $account_id"
    else
        echo -e "${RED}  ✗ AWS credentials NOT configured${NC}"
        echo -e "${YELLOW}  Configure with: aws configure${NC}"
        ALL_CHECKS_PASSED=false
    fi
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
    echo "  unzip awscliv2.zip"
    echo "  sudo ./aws/install"
fi
echo ""

# Check kubectl
echo "4. kubectl (Kubernetes CLI)"
if check_command "kubectl" "1.28" "version --client"; then
    :
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  curl -LO 'https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'"
    echo "  chmod +x kubectl"
    echo "  sudo mv kubectl /usr/local/bin/"
fi
echo ""

# Check Helm
echo "5. Helm (Kubernetes package manager)"
if check_command "helm" "3.12" "version"; then
    :
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
fi
echo ""

# Check yq
echo "6. yq (YAML processor)"
if check_command "yq" "4.0" "--version"; then
    :
else
    echo -e "${YELLOW}  Install with:${NC}"
    echo "  sudo wget -qO /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64"
    echo "  sudo chmod +x /usr/bin/yq"
fi
echo ""

# Check for Terraform (optional - might cause confusion)
echo "7. Checking for Terraform (should NOT be present)"
if command -v terraform &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} Terraform is installed alongside OpenTofu"
    terraform_version=$(terraform version -json 2>/dev/null | grep -oP '"terraform_version":"\K[^"]+' || terraform version 2>&1 | head -1)
    echo "  Version: $terraform_version"
    echo -e "${YELLOW}  Note: This may cause confusion. Consider removing Terraform:${NC}"
    echo "  sudo rm \$(which terraform)"
else
    echo -e "${GREEN}✓${NC} Terraform not found (good - using OpenTofu instead)"
fi
echo ""

# Check Terragrunt OpenTofu preference
echo "8. Checking Terragrunt configuration"
if command -v terragrunt &> /dev/null && command -v tofu &> /dev/null; then
    if [[ -n "${TERRAGRUNT_TFPATH:-}" ]]; then
        echo -e "${GREEN}✓${NC} TERRAGRUNT_TFPATH is set to: $TERRAGRUNT_TFPATH"
    else
        echo -e "${YELLOW}⚠${NC} TERRAGRUNT_TFPATH is not set"
        echo "  Terragrunt will auto-detect OpenTofu"
        echo "  To explicitly use OpenTofu, run:"
        echo "  export TERRAGRUNT_TFPATH=tofu"
    fi
fi
echo ""

# Final summary
echo "======================================"
if [ "$ALL_CHECKS_PASSED" = true ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "You're ready to use OpenTofu with this installer."
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo "Please install missing tools before proceeding."
fi
echo "======================================"
echo ""

# Additional recommendations
echo "Recommendations:"
echo "1. Set environment variable for Terragrunt to use OpenTofu:"
echo "   export TERRAGRUNT_TFPATH=tofu"
echo ""
echo "2. Review the OpenTofu migration guide:"
echo "   cat OPENTOFU_MIGRATION.md"
echo ""
echo "3. Test OpenTofu with a simple init:"
echo "   cd template && tofu init"
echo ""

exit $([ "$ALL_CHECKS_PASSED" = true ] && echo 0 || echo 1)
