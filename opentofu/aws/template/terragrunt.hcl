generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "local" {
    path = "${get_parent_terragrunt_dir()}/.terraform/${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}

generate "variables" {
  path      = "variables.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "aws_account_id" {
  description = "Target AWS Account ID"
  type        = string
}
EOF
}
 
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::$${var.aws_account_id}:role/lms-cross-account-codebuild-role"
  }
}
EOF
}