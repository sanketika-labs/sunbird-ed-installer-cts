locals {
  global_vars     = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  environment     = local.global_vars.global.environment
  building_block  = local.global_vars.global.building_block
  aws_region      = local.global_vars.global.cloud_storage_region
}

terraform {
  source = "../../modules//upload-files/"
}

dependency "storage" {
  config_path = "../storage"
  mock_outputs_merge_strategy_with_state = "shallow"
  mock_outputs = {
    storage_bucket_public  = "dummy-public-bucket"
    storage_bucket_private = "dummy-private-bucket"
  }
}

inputs = {
  environment                        = local.environment
  building_block                     = local.building_block
  aws_region                         = local.aws_region
  storage_bucket_public              = dependency.storage.outputs.storage_bucket_public
  storage_bucket_private             = dependency.storage.outputs.storage_bucket_private
  sunbird_public_artifacts_bucket    = lookup(local.global_vars.global, "sunbird_public_artifacts_bucket", "sunbird-public-artifacts")
  sunbird_public_artifacts_prefix    = lookup(local.global_vars.global, "sunbird_public_artifacts_prefix", "artifacts")
}
