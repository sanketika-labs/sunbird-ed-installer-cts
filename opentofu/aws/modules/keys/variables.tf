variable "environment" {
  description = "Environment name"
  type        = string
}

variable "building_block" {
  description = "Building block name"
  type        = string
}

variable "base_location" {
  description = "Base location for file paths"
  type        = string
}

variable "rsa_keys_count" {
  description = "Number of RSA keys to generate"
  type        = number
  default     = 3
}
