locals {
  global_vars     = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  aws_region      = local.global_vars.global.cloud_storage_region
  environment     = local.global_vars.global.environment
  building_block  = local.global_vars.global.building_block
}
 
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  assume_role {
    role_arn     = "arn:aws:iam::${local.target_account}:role/lms-cross-account-codebuild-role"
    session_name = "terragrunt-deployment"
  }
  default_tags {
    tags = {
      Environment   = "${local.environment}"
      BuildingBlock = "${local.building_block}"
      ManagedBy     = "Terragrunt"
    }
  }
}
EOF
}