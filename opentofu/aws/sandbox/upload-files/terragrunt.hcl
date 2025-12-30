include "base" {
  path   = "${get_terragrunt_dir()}/../_base.hcl"
  expose = true
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "environment" {
  path = "${get_terragrunt_dir()}/../../_common/upload-files.hcl"
}
