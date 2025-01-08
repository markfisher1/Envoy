terraform {
  source = "git::ssh://xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

include {
  path = find_in_parent_folders()
}

locals {
  common_inputs      = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  region_inputs      = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  environment_inputs = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
  privatelink_account_url              = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  privatelink_vpce_id                  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  privatelink_ocsp_url                 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  regionless_privatelink_account_url   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  regionless_privatelink_ocsp_url      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  regionless_snowsight_privatelink_url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Additional CIDRs
  sg_additional_cidrs = [
     "xxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxxxxx",
    "xxxxxxxxxxxxxx",
    "1xxxxxxxxxxxxxxxx",
    "1xxxxxxxxxxxxxxxxxx",
    "1xxxxxxxxxxxxxxxx",
 
  ]
}
