data "aws_identitystore_user" "aws_user" {
  for_each = { for config in local.unique_user_configurations : "${config.account}.${config.username}" => config }

  identity_store_id = element(var.identity_store_ids, 0)
  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.username
    }
  }
}

data "aws_identitystore_group" "aws_group" {
  for_each = { for config in local.unique_group_configurations : "${config.account}.${config.groupname}" => config }

  identity_store_id = element(var.identity_store_ids, 0)
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.groupname
    }
  }
  depends_on = [aws_identitystore_group.aws_group]
}

data "aws_ssoadmin_permission_set" "aws_user_permissionset" {
  for_each = { for config in local.flatten_user_configurations : "${config.account}.${config.username}.${config.permissionset}" => config }

  instance_arn = element(var.ssoadmin_instance_arns, 0)
  name         = each.value.permissionset
  depends_on   = [aws_ssoadmin_permission_set.permissionset]
}

data "aws_ssoadmin_permission_set" "aws_group_permissionset" {
  for_each = { for config in local.flatten_group_configurations : "${config.account}.${config.groupname}.${config.permissionset}" => config }

  instance_arn = element(var.ssoadmin_instance_arns, 0)
  name         = each.value.permissionset
  depends_on   = [aws_ssoadmin_permission_set.permissionset]
}
