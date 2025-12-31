locals {
  environment_name = "${var.building_block}-${var.environment}"
  
  common_tags = {
    Environment    = var.environment
    BuildingBlock  = var.building_block
    ManagedBy      = "OpenTofu"
    CloudProvider  = "AWS"
  }
}

# IAM user for storage access
resource "aws_iam_user" "storage_user" {
  name = "${local.environment_name}-storage-user"
  path = "/"
  
  tags = merge(
    local.common_tags,
    {
      Name    = "${local.environment_name}-storage-user"
      Purpose = "S3 bucket access for application"
    }
  )
}

# Access key for the storage user
resource "aws_iam_access_key" "storage_user" {
  user = aws_iam_user.storage_user.name
}

# IAM policy for storage bucket access
resource "aws_iam_user_policy" "storage_access" {
  name = "${local.environment_name}-storage-access-policy"
  user = aws_iam_user.storage_user.name
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = [
          var.public_bucket_arn,
          var.private_bucket_arn,
          var.dial_bucket_arn,
          var.velero_bucket_arn
        ]
      },
      {
        Sid    = "ObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          "${var.public_bucket_arn}/*",
          "${var.private_bucket_arn}/*",
          "${var.dial_bucket_arn}/*",
          "${var.velero_bucket_arn}/*"
        ]
      },
      {
        Sid    = "ListAllBuckets"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ]
        Resource = "*"
      }
    ]
  })
}
