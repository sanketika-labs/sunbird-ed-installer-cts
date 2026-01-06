locals {
#   global_values_keys_file         = "${var.base_location}/../global-keys-values.yaml"
  jwt_script_location             = "${var.base_location}/../../../../scripts/jwt-keys.py"
  rsa_script_location             = "${var.base_location}/../../../../scripts/rsa-keys.py"
  global_values_jwt_file_location = "${var.base_location}/../../../../scripts/global-values-jwt-tokens.yaml"
  global_values_rsa_file_location = "${var.base_location}/../../../../scripts/global-values-rsa-keys.yaml"
}

resource "random_password" "generated_string" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "encryption_string" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "null_resource" "generate_jwt_keys" {
  triggers = {
    command = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<EOT
      python3 ${local.jwt_script_location} ${random_password.generated_string.result} && \
      yq eval-all 'select(fileIndex == 0) *+ {"global": (select(fileIndex == 0).global * load("${local.global_values_jwt_file_location}"))}' -i ${var.base_location}/../global-values.yaml
    EOT
  }
}

resource "null_resource" "generate_rsa_keys" {
  triggers = {
    command = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<EOT
      python3 ${local.rsa_script_location} ${var.rsa_keys_count} && \
      yq eval-all 'select(fileIndex == 0) *+ {"global": (select(fileIndex == 0).global * load("${local.global_values_rsa_file_location}"))}' -i ${var.base_location}/../global-values.yaml
    EOT
  }
}
