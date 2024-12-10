output "envoy_config_secret_arn" {
  description = "ARN of the Envoy configuration secret in Secrets Manager"
  value       = aws_secretsmanager_secret.envoy_config.arn
}

output "vpc_endpoint_security_group_id" {
  description = "Security Group ID for VPC endpoint"
  value       = aws_security_group.vpc_endpoint.id
}
