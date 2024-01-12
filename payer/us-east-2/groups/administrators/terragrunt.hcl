terraform {
  source = "git@github.com:marquesmateus93/terraform-iam.git//modules/groups//."
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

dependency "roles_read_only" {
  config_path   = "../../roles/read_only"
  skip_outputs  = true
}

inputs = {
  group_name  = basename(get_terragrunt_dir())
  path        = "/${local.prefix_name}/${local.environment_folder}/"

  arn_roles = [
    "arn:aws:iam::${get_aws_account_id()}:role/${local.prefix_name}/${local.environment_folder}/${basename(get_terragrunt_dir())}"
  ]
}
