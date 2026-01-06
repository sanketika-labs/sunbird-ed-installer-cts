locals {
  global_vars     = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  environment     = local.global_vars.global.environment
  building_block  = local.global_vars.global.building_block
}

terraform {
  source = "../../modules//storage-user/"
}

dependency "storage" {
  config_path = "../storage"
  mock_outputs = {
    storage_bucket_public_arn  = "arn:aws:s3:::dummy-public"
    storage_bucket_private_arn = "arn:aws:s3:::dummy-private"
    dial_bucket_arn            = "arn:aws:s3:::dummy-dial"
    velero_bucket_arn          = "arn:aws:s3:::dummy-velero"
  }
}

inputs = {
  environment         = local.environment
  building_block      = local.building_block
  public_bucket_arn   = dependency.storage.outputs.storage_bucket_public_arn
  private_bucket_arn  = dependency.storage.outputs.storage_bucket_private_arn
  dial_bucket_arn     = dependency.storage.outputs.dial_bucket_arn
  velero_bucket_arn   = dependency.storage.outputs.velero_bucket_arn
}
