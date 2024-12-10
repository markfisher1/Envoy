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
