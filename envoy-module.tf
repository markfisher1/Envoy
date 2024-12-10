resource "aws_secretsmanager_secret" "envoy_config" {
  name        = "envoy-config-secret"
  description = "Secret to store the Envoy configuration file"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "envoy_config_version" {
  secret_id     = aws_secretsmanager_secret.envoy_config.id
  secret_string = file("${path.module}/envoy-config.yaml")
}

resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "snowflake-vpc-endpoint-sg-"
  description = "Security Group for snowflake endpoint"
  vpc_id      = var.vpc_id

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "vpc_endpoint_egress" {
  description       = "outbound"
  security_group_id = aws_security_group.vpc_endpoint.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
