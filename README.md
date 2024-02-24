# [Terraform AWS SSO Module](https://registry.terraform.io/modules/GirishCodeAlchemy/sso-module/aws/latest)

This Terraform module is designed to provision and configure AWS SSO (Single Sign-On) resources, including identity store, users, groups, and permissions.

> Empower your AWS environment with the flexibility to manage multiple hierarchies seamlessly. Our Terraform AWS SSO Module simplifies the orchestration of accounts, users, groups, and permission sets, ensuring you have the agility to handle diverse configurations effortlessly

![](./flow-diagram.gif)

## Usage

```hcl
data "aws_ssoadmin_instances" "ssoadmin" {

}

module "sso" {
  source  = "GirishCodeAlchemy/sso-module/aws"
  version = "1.0.0"

  identity_store_ids           = data.aws_ssoadmin_instances.ssoadmin.identity_store_ids
  ssoadmin_instance_arns       = data.aws_ssoadmin_instances.ssoadmin.arns
  sso_user_configmap           = var.sso_user_configmap
  sso_groups_configmap         = var.sso_groups_configmap
  sso_permissionsets_configmap = var.sso_permissionsets_configmap
  sso_account_configmap        = var.sso_account_configmap
}
```

## Variables

### 1. `identity_store_ids`

List of Identity Store IDs to search for users and groups.

```hcl
variable "identity_store_ids" {
  description = "List of Identity Store IDs to search for users and groups."
  type        = list(string)
}
```

**example:**

```hcl
identity_store_ids = ["d-sdff8b57"]
```

### 2. `ssoadmin_instance_arns`

List of Identity Store Instance ARNs to search for users and groups.

```hcl
variable "ssoadmin_instance_arns" {
  description = "List of Identity Store Instance ARNs to search for users and groups."
  type        = list(string)
}

```

**example:**

```hcl
ssoadmin_instance_arns = ["arn:aws:sso:::instance/ssoins-xxxxxxxxxx"]
```

### 3. `sso_user_configmap`

Configuration for SSO Users.

```hcl
variable "sso_user_configmap" {
  description = "This sets the configuration for SSO Users"
  type = map(object({
    display_name = string
    user_name    = string
    given_name   = string
    family_name  = string
    email        = string
  }))
}

```

**example:**

```hcl
sso_user_configmap = {
  girish1 = {
    display_name = "Girish V"
    user_name    = "girish1"
    given_name   = "Girish"
    family_name  = "V"
    email        = "girish1@example.com"
  },
  girish2 = {
    display_name = "Girish V"
    user_name    = "girish2"
    given_name   = "Girish"
    family_name  = "V"
    email        = "girish2@example.com"
  }
}
```

### 4. `sso_groups_configmap`

Configuration for SSO Groups and Members.

> [!IMPORTANT]
> v1: Currently, groups and members will only be created if those users are created using the `sso_user_configmap`.\
> \
> For assistance in adding `existing users`, who were manually created on the AWS console, and mapping them to the existing `Group` and `Member`, please await the release of version 2 of this module.

```hcl
variable "sso_groups_configmap" {
  description = "This sets the configuration for SSO Users"
  type = map(object({
    display_name = string
    description  = string
    users        = list(string)
  }))
}

```

**example:**

```hcl
sso_groups_configmap = {
  "L1-devops-group" = {
    display_name = "L1-devops-group"
    description  = "This is AWS L1 Devops Group"
    users        = ["girish1", "girish2"]
  },
  "L1-Admin-group" = {
    display_name = "L1-Admin-group"
    description  = "This is AWS L1 Admin Group"
    users        = ["girish1"]
  }
}
```

### 5. `sso_permissionsets_configmap`

Configuration for AWS SSO Permission Sets with Managed Policy and Inline Policy

> [!IMPORTANT]
> list of managed policies can be attached to the permission set.

> [!CAUTION]
> Please note the following validation conditions:
>
> - The Permissionset Name key must be less than 31 characters in sso_permissionsets_configmap.
> - At least one of managed_policy_arns or inline_policy must be set in sso_permissionsets_configmap

```hcl
variable "sso_permissionsets_configmap" {
  type = map(object({
    name                = string
    description         = string
    managed_policy_arns = list(string)
    inline_policy       = string
  }))
  validation {
    condition     = length(values(var.sso_permissionsets_configmap)[*].name) <= 31
    error_message = "The Permissionset Name key must be less than 31 characters in sso_permissionsets_configmap."
  }
  validation {
    condition     = alltrue([for v in values(var.sso_permissionsets_configmap) : length(v.managed_policy_arns) > 0 || v.inline_policy != ""])
    error_message = "At least one of managed_policy_arns or inline_policy must be set in sso_permissionsets_configmap."
  }
}
```

**example:**

```hcl
sso_permissionsets_configmap = {
  "SSM-Admin-permissionset" = {
    name                = "SSM-Admin-permissionset"
    description         = "Sample Admin permissionset"
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess", "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
    inline_policy       = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": [
                "lambda:*",
            ],
            "Resource": "*"
            }
        ]
    }
    EOF
  },
  "SSM-testing-permissionset" = {
    name                = "SSM-testing-permissionset"
    description         = "Sample testing permissionset"
    managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
    inline_policy       = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::*"
            }
        ]
    }
    EOF
  }
}
```

### 6. `sso_account_configmap`

Configuration for SSO Account.

> [!IMPORTANT]
> Supported scenarios include:
>
> - Mapping old users, groups, and permission sets.
> - Mapping new users, groups, and permission sets created using this module.
> - Migrating a combination of both old and new SSO configurations.
> - Supporting SSO creation for multiple account creations.
> - Supporting the creation of multiple users, groups, and permission sets.

```hcl
variable "sso_account_configmap" {
  description = "This sets the configuration for SSO account"
  type = map(object({
    users = map(object({
      username      = string
      permissionset = list(string)
    }))
    groups = map(object({
      groupname     = string
      permissionset = list(string)
    }))
  }))
}

```

**example:**

```hcl
sso_account_configmap = {
  "1xxxxxxxx" = {
    users = {
      girishcodealchemy = { username = "girishcodealchemy", permissionset = ["SSM-testing-permissionset", "SSM-Admin-permissionset"] }
    }
    groups = {
      L1devopsgroup = { groupname = "L1-devops-group", permissionset = ["SSM-testing-permissionset", "SSM-Admin-permissionset"] }
    }
  },
  "2xxxxxxxx" = {
    users = {
      girishcodealchemy = { username = "girishcodealchemy", permissionset = ["SSM-testing-permissionset"] }
    }
    groups = {
      L1devopsgroup = { groupname = "L1-devops-group", permissionset = ["SSM-testing-permissionset"] },
      L1AdminGroup  = { groupname = "L1-Admin-group", permissionset = ["SSM-Admin-permissionset"] }
    }
  }
}
```
