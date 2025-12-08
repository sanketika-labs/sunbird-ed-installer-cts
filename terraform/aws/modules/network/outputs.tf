output "vpc_id" {
  description = "VPC ID"
  value       = var.create_network == "true" ? module.vpc[0].vpc_id : data.aws_vpc.existing[0].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = var.create_network == "true" ? module.vpc[0].private_subnets : data.aws_subnets.existing_private[0].ids
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = var.create_network == "true" ? module.vpc[0].public_subnets : data.aws_subnets.existing_public[0].ids
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = var.create_network == "true" ? module.vpc[0].vpc_cidr_block : data.aws_vpc.existing[0].cidr_block
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = var.create_network == "true" ? module.vpc[0].natgw_ids : []
}
