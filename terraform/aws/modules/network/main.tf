locals {
  environment_name = "${var.building_block}-${var.environment}"
  
  common_tags = {
    Environment    = var.environment
    BuildingBlock  = var.building_block
    ManagedBy      = "Terraform"
    CloudProvider  = "AWS"
  }
}

# VPC Module using terraform-aws-modules/vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  count = var.create_network == "true" ? 1 : 0
  
  name = "${local.environment_name}-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["${var.aws_region}a"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Tags for Kubernetes
  public_subnet_tags = {
    "kubernetes.io/role/elb"                                = "1"
    "kubernetes.io/cluster/${local.environment_name}-cluster" = "shared"
  }
  
  # private_subnet_tags = {
  #   "kubernetes.io/role/internal-elb"                       = "1"
  #   "kubernetes.io/cluster/${local.environment_name}-cluster" = "shared"
  # }
  
  tags = local.common_tags
}

# Data sources for existing VPC (if create_network is false)
data "aws_vpc" "existing" {
  count = var.create_network == "false" ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "existing_private" {
  count = var.create_network == "false" ? 1 : 0
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "existing_public" {
  count = var.create_network == "false" ? 1 : 0
  
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  tags = {
    Tier = "Public"
  }
}
