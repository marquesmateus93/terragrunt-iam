terraform {
  source = "git@github.com:marquesmateus93/terraform-iam.git//modules/roles//."
}

include {
  path = find_in_parent_folders()
}

locals {
  environment = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account     = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  environment_folder  = local.environment.locals.environment_folder
  prefix_name         = local.account.locals.prefix_name
}

dependency "tags" {
  config_path   = "../../tags"

  mock_outputs = {
    prefix_name = "dummy_name"
    environment = "dummy_environment"
    creator_id  = get_aws_caller_identity_user_id()
  }
}

inputs = {
  role_name  = basename(get_terragrunt_dir())

  path = "/${local.prefix_name}/${local.environment_folder}/"

  arn_root    = [
    "arn:aws:iam::${get_aws_account_id()}:root"
  ]

  tags = {
    environment = dependency.tags.outputs.environment
    creator_id  = dependency.tags.outputs.creator_id
  }
}
