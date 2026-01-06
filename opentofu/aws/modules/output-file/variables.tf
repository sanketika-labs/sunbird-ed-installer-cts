variable "env" {
  description = "Short environment name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "building_block" {
  description = "Building block name"
  type        = string
}

variable "aws_s3_public_bucket" {
  description = "Public S3 bucket name"
  type        = string
}

variable "aws_s3_private_bucket" {
  description = "Private S3 bucket name"
  type        = string
}

variable "aws_s3_dial_bucket" {
  description = "DIAL state S3 bucket name"
  type        = string
}

variable "aws_s3_velero_bucket" {
  description = "Velero backup S3 bucket name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS OIDC provider URL (without https://)"
  type        = string
}

variable "sunbird_sa_role_arn" {
  description = "ARN of Sunbird service account IAM role"
  type        = string
}

variable "velero_sa_role_arn" {
  description = "ARN of Velero service account IAM role"
  type        = string
}

variable "private_ingressgateway_ip" {
  description = "Private ingress gateway IP/hostname"
  type        = string
}

variable "encryption_string" {
  description = "Encryption string from keys module"
  type        = string
  sensitive   = true
}

variable "random_string" {
  description = "Random string from keys module"
  type        = string
  sensitive   = true
}

variable "cloud_storage_provider" {
  description = "Cloud storage provider"
  type        = string
  default     = "aws"
}

variable "base_location" {
  description = "Base location for file paths"
  type        = string
}

variable "cloud_storage_access_key" {
  description = "Storage user access key ID"
  type        = string
  sensitive   = true
}

variable "cloud_storage_secret_key" {
  description = "Storage user secret access key"
  type        = string
  sensitive   = true
}
