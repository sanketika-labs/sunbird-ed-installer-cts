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

variable "storage_bucket_public" {
  description = "Public S3 bucket name"
  type        = string
}

variable "storage_bucket_private" {
  description = "Private S3 bucket name"
  type        = string
}

variable "sunbird_public_artifacts_bucket" {
  description = "Sunbird public artifacts bucket name"
  type        = string
  default     = "sunbird-public-artifacts"
}

variable "sunbird_public_artifacts_prefix" {
  description = "Sunbird public artifacts prefix/path"
  type        = string
  default     = "artifacts"
}
