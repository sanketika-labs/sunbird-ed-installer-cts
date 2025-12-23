locals {
  global_vars         = yamldecode(file(find_in_parent_folders("global-values.yaml")))
  environment         = local.global_vars.global.environment
  building_block      = local.global_vars.global.building_block
  aws_region          = local.global_vars.global.cloud_storage_region
  eks_cluster_version = lookup(local.global_vars.global, "eks_cluster_version", "1.28")
}

terraform {
  source = "../../modules//eks/"
}

dependency "network" {
  config_path = "../network"
  mock_outputs = {
    vpc_id              = "vpc-dummy"
    public_subnet_ids   = ["subnet-dummy-3", "subnet-dummy-4"]
  }
}

inputs = {
  environment             = local.environment
  building_block          = local.building_block
  aws_region              = local.aws_region
  vpc_id                  = dependency.network.outputs.vpc_id
  public_subnet_ids       = dependency.network.outputs.public_subnet_ids
  cluster_version         = local.eks_cluster_version
  node_instance_type      = lookup(local.global_vars.global, "eks_node_instance_type", "m5.2xlarge")
  node_disk_size_gb       = lookup(local.global_vars.global, "eks_node_disk_size_gb", 100)
  node_count_min          = lookup(local.global_vars.global, "eks_node_count_min", 3)
  node_count_max          = lookup(local.global_vars.global, "eks_node_count_max", 10)
}
