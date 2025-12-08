variable "environment" {
  description = "Environment name"
  type        = string
}

variable "building_block" {
  description = "Building block name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS cluster"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for load balancers"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m5a.12xlarge"
}

variable "node_disk_size_gb" {
  description = "Disk size for worker nodes in GB"
  type        = number
  default     = 100
}

variable "node_count_min" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 0
}

variable "node_count_max" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 1
}
