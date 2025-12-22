#!/bin/bash
# Quick fix script to upgrade Terragrunt for OpenTofu support

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                            ║"
echo "║                    Terragrunt Upgrade for OpenTofu                         ║"
echo "║                                                                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check current version
if command -v terragrunt &> /dev/null; then
    current_version=$(terragrunt --version 2>&1 | head -1)
    echo "Current Terragrunt: $current_version"
else
    echo "Terragrunt not found - will install fresh"
    current_version="not installed"
fi

echo ""
echo "OpenTofu requires Terragrunt v0.48.0 or higher"
echo ""

# Ask for confirmation
read -p "Proceed with upgrade to latest version? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Upgrading Terragrunt..."

# Backup old version if exists
if command -v terragrunt &> /dev/null; then
    terragrunt_path=$(which terragrunt)
    echo "Backing up old version..."
    sudo cp "$terragrunt_path" "${terragrunt_path}.backup.$(date +%Y%m%d)" || true
fi

# Download latest
echo "Downloading latest Terragrunt..."
wget -q --show-progress https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64

# Install
echo "Installing..."
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Verify
echo ""
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                           UPGRADE COMPLETE ✅                              ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

new_version=$(terragrunt --version 2>&1 | head -1)
echo "New Terragrunt: $new_version"
echo ""

# Check if it's >= 0.48.0
version_number=$(echo "$new_version" | grep -oP 'v\d+\.\d+\.\d+' || echo "")
if [[ -n "$version_number" ]]; then
    major=$(echo "$version_number" | cut -d'v' -f2 | cut -d'.' -f1)
    minor=$(echo "$version_number" | cut -d'.' -f2)
    
    if [[ $major -eq 0 && $minor -ge 48 ]] || [[ $major -gt 0 ]]; then
        echo "✅ Terragrunt now supports OpenTofu!"
    else
        echo "⚠️  Warning: Version might still be too old for OpenTofu"
    fi
fi

echo ""
echo "You can now run: terragrunt init"
echo ""
