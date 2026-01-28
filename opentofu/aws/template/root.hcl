locals {
  global_vars = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  aws_region  = local.global_vars.global.cloud_storage_region
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket = "lms-sunbird-terraform-states-s3"
    key    = "terraform-states/lms-platform/dev/lms_sunbird_ed_installer.tfstate"
    region = "${local.aws_region}"
    encrypt = true
  }
}
EOF
}