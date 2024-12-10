output "envoy_secret_arn" {
  value = aws_secretsmanager_secret.envoy_config.arn
}
