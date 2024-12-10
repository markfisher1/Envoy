# Envoy
The envoy configuration introduces separate functionality (e.g., application-layer logic and traffic management), modularizing it improves code reusability and separation of concerns.


---

## Project Structure

- **`main.tf`**: Main configuration file.

- **`envoy-config.yaml`**: Envoy proxy configuration.

- **`envoy-module.tf`**: Manages Envoy and AWS resources.

- **`outputs.tf`**: Outputs for the Terraform module.

- **`README.md`**: Documentation.

---


## Create a New Module


Create a standalone module for Envoy:


1. Create a New Directory:


Define Envoy Resources: In main.tf:



terraform {
    
  source = "git::ssh://git@gitlab.disney.com/pto/tf-modules/data-platform/snowflake/aws-privatelink.git?ref=v1.0.4"

}

include {

  path = find_in_parent_folders()

}

locals {

  common_inputs      = read_terragrunt_config(find_in_parent_folders("common.hcl"))

  region_inputs      = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_inputs = read_terragrunt_config(find_in_parent_folders("environment.hcl"))

}


dependency "network" {

  config_path = "../network"

}

module "envoy" {

  source       = "./envoy-module.tf"

  envoy_config = file("${path.module}/envoy-config.yaml")

}

inputs = {

  project_data = merge(local.common_inputs.inputs.project_data)

  region       = local.region_inputs.inputs.region

  tags         = merge(local.common_inputs.inputs.tags, local.environment_inputs.inputs.tags)

  # Network inputs

  vpc_id = dependency.network.outputs.vpc_id

  # Snowflake PrivateLink inputs

  privatelink_account_url              = "odb35213.us-east-1.privatelink.snowflakecomputing.com"

  privatelink_vpce_id                  = "com.amazonaws.vpce.us-east-1.vpce-svc-0ddfafc93f4619001"

  privatelink_ocsp_url                 = "ocsp.odb35213.us-east-1.privatelink.snowflakecomputing.com"

  regionless_privatelink_account_url   = "disneystudios-prod.privatelink.snowflakecomputing.com"

  regionless_privatelink_ocsp_url      = "ocsp.disneystudios-prod.privatelink.snowflakecomputing.com"

  regionless_snowsight_privatelink_url = "app-disneystudios-prod.privatelink.snowflakecomputing.com"

  # Additional CIDRs
  sg_additional_cidrs = [
     "10.0.0.0/8",
    "138.69.236.0/24",
    "139.104.0.0/16",
    "149.122.160.0/24",
    "149.122.41.64/26",
    "153.6.0.0/16",
    "153.7.0.0/16",
    "153.8.0.0/16",
    "157.23.0.0/16",
    "167.13.0.0/16",
    "172.16.0.0/12",
    "192.168.0.0/16",
    "192.195.63.0/24",
    "192.195.64.0/22",
    "193.202.6.32/29",
    "198.162.92.64/28",
    "199.181.130.48/28",
    "199.4.128.0/24",
    "204.238.46.64/27",
    "206.18.40.0/24",
    "204.128.192.0/24",
    "100.64.0.0/16"
  ]
}



### Module for Envoy configuration

2. Envoy proxy configuration : envoy-config.yaml: 

    static_resources:
    listeners:
        - name: listener_0
        address:
            socket_address:
            address: 0.0.0.0
            port_value: 10000
        filter_chains:
            - filters:
                - name: envoy.filters.network.http_connection_manager
                typed_config:
                    "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                    stat_prefix: ingress_http
                    route_config:
                    name: local_route
                    virtual_hosts:
                        - name: backend
                        domains: ["*"]
                        routes:
                            - match:
                                prefix: "/"
                            route:
                                cluster: backend
                    http_filters:
                    - name: envoy.filters.http.router
    clusters:
        - name: backend
        connect_timeout: 0.25s
        type: LOGICAL_DNS
        lb_policy: ROUND_ROBIN
        load_assignment:
            cluster_name: backend
            endpoints:
            - lb_endpoints:
                - endpoint:
                    address:
                        socket_address:
                        address: example.com
                        port_value: 443
        transport_socket:
            name: envoy.transport_sockets.tls
            typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext

---

3. Manages Envoy and AWS resources: envoy-module.tf:

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



4. Output the Configuration: In outputs.tf:


    output "envoy_config_secret_arn" {
    description = "ARN of the Envoy configuration secret in Secrets Manager"
    value       = aws_secretsmanager_secret.envoy_config.arn
    }

    output "vpc_endpoint_security_group_id" {
    description = "Security Group ID for VPC endpoint"
    value       = aws_security_group.vpc_endpoint.id
    }




5. Call the Module: Reference this module in your existing deployment:


    module "envoy" {

    source       = "./envoy-module"

    envoy_config = file("${path.module}/envoy-config.yaml")

    }



6. Add Envoy to the Deployment Pipeline: 

Update your CI/CD pipeline to include the deployment of Envoy's configuration.

---

## Recommendation

Given the complexity of Envoy and the scope of the aws-privatelink file, 

it's best to create a separate module to ensure clean and maintainable code. 

Then, link it to the existing infrastructure using Terraform outputs and inputs.

---




## Prerequisites

- AWS account and IAM permissions.
- Terraform CLI installed.
- Git access to Disney's Terraform module repository.

---

## Steps to Deploy

1. Initialize Terraform:

--terraform init

2. Plan the deployment:

--terraform plan

3. Apply the configuration:

--terraform apply

---

## Outputs

envoy_config_secret_arn: ARN of the Envoy configuration in Secrets Manager.

vpc_endpoint_security_group_id: ID of the security group for Snowflake PrivateLink.