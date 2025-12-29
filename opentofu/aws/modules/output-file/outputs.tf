output "global_cloud_values_file" {
  description = "Path to the global cloud values YAML file"
  value       = local_sensitive_file.global_cloud_values_yaml.filename
}
