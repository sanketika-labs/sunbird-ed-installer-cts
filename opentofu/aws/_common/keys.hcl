locals {
  global_vars     = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  environment     = local.global_vars.global.environment
  building_block  = local.global_vars.global.building_block
}

terraform {
  source = "../../modules//keys/"
}

inputs = {
  environment     = local.environment
  building_block  = local.building_block
  base_location   = get_terragrunt_dir()
}
