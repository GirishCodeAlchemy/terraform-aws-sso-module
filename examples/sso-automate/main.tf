provider "aws" {
  region = "eu-west-1"
}

data "aws_ssoadmin_instances" "ssoadmin" {}

module "sso" {
  source                       = "../../"
  identity_store_ids           = data.aws_ssoadmin_instances.ssoadmin.identity_store_ids
  ssoadmin_instance_arns       = data.aws_ssoadmin_instances.ssoadmin.arns
  sso_user_configmap           = var.sso_user_configmap
  sso_groups_configmap         = var.sso_groups_configmap
  sso_permissionsets_configmap = var.sso_permissionsets_configmap
  sso_account_configmap        = var.sso_account_configmap
}
