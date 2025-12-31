output "storage_user_name" {
  description = "IAM user name for storage access"
  value       = aws_iam_user.storage_user.name
}

output "storage_user_arn" {
  description = "IAM user ARN for storage access"
  value       = aws_iam_user.storage_user.arn
}

output "storage_access_key_id" {
  description = "Access key ID for storage user"
  value       = aws_iam_access_key.storage_user.id
  sensitive   = true
}

output "storage_secret_access_key" {
  description = "Secret access key for storage user"
  value       = aws_iam_access_key.storage_user.secret
  sensitive   = true
}
