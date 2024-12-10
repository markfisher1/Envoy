variable "envoy_config" {
  description = "Envoy configuration for traffic management."
  type        = string
}

resource "aws_secretsmanager_secret" "envoy_config" {
  name        = "envoy-configuration"
  description = "Stores Envoy traffic management configurations"
}

resource "aws_secretsmanager_secret_version" "envoy_config_version" {
  secret_id     = aws_secretsmanager_secret.envoy_config.id
  secret_string = var.envoy_config
}
