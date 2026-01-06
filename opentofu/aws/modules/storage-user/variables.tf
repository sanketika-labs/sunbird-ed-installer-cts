variable "environment" {
  description = "Environment name"
  type        = string
}

variable "building_block" {
  description = "Building block name"
  type        = string
}

variable "public_bucket_arn" {
  description = "ARN of the public S3 bucket"
  type        = string
}

variable "private_bucket_arn" {
  description = "ARN of the private S3 bucket"
  type        = string
}

variable "dial_bucket_arn" {
  description = "ARN of the DIAL S3 bucket"
  type        = string
}

variable "velero_bucket_arn" {
  description = "ARN of the Velero backup S3 bucket"
  type        = string
}
