resource "null_resource" "copy_from_sunbird_artifacts" {
  triggers = {
    command = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<EOT
      aws s3 sync \
        s3://${var.sunbird_public_artifacts_bucket}/artifacts \
        s3://${var.storage_bucket_public}/ \
        --no-progress \
        --exclude "*.terragrunt-source-manifest" \
        --only-show-errors
    EOT
  }
}

locals {
  template_files = fileset("${path.module}/sunbird-rc/schemas", "*.json")
}

resource "local_file" "rc_schema_files" {
  for_each = toset(local.template_files)
  
  content = templatefile("${path.module}/sunbird-rc/schemas/${each.value}", {
    cloud_storage_schema_url = "https://${var.storage_bucket_public}.s3.${var.aws_region}.amazonaws.com"
  })
  
  filename = "${path.module}/sunbird-rc/schemas/${each.value}"
}

resource "null_resource" "upload_rc_schemas" {
  triggers = {
    schemas_hash = md5(jsonencode([for f in local_file.rc_schema_files : f.content]))
  }
  
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/sunbird-rc/schemas s3://${var.storage_bucket_public}/schemas --exclude '*.tf' --only-show-errors"
  }
  
  depends_on = [local_file.rc_schema_files]
}
