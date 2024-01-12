terraform {
  source = "git@github.com:marquesmateus93/terraform-iam.git//modules/users//."
}

include {
  path = find_in_parent_folders()
}

locals {
  users-groups        = read_terragrunt_config(find_in_parent_folders("users-groups.hcl"))
  environment         = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  users_groups_locals = local.users-groups.locals
  environment_folder  = local.environment.locals.environment_folder
}

dependency "tags" {
  config_path   = "../tags"
  mock_outputs = {
    prefix_name = "dummy_name"
    environment = "dummy_environment"
    creator_id  = get_aws_caller_identity_user_id()
  }
}

dependency "groups_read_only" {
  config_path   = "../groups/read_only"
  skip_outputs  = true
}

inputs = {
  users = {
    groups_users        = local.users_groups_locals
    environment_folder  = local.environment_folder
    prefix_name         = dependency.tags.outputs.prefix_name
  }

  tags = {
    prefix_name = dependency.tags.outputs.prefix_name
    environment = dependency.tags.outputs.environment
    creator_id  = dependency.tags.outputs.creator_id
  }
}
