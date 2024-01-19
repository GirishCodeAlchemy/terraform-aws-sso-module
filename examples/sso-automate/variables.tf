variable "sso_user_configmap" {
  description = "This sets the configuration for SSO Users"
  type = map(object({
    display_name = string
    user_name    = string
    given_name   = string
    family_name  = string
    email        = string
  }))
  default = {
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
}

variable "sso_groups_configmap" {
  description = "This sets the configuration for SSO Users"
  type = map(object({
    display_name = string
    description  = string
    users        = list(string)
  }))
  default = {
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
}

variable "sso_permissionsets_configmap" {
  type = map(object({
    description         = string
    managed_policy_arns = list(string)
    inline_policy       = string
  }))
  default = {
    "SSM-Admin-permissionset" = {
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
    },
    "SSM-Only-Managed-permissionset" = {
      description         = "Sample testing permissionset"
      managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEC2FullAccess"]
      inline_policy       = ""
    },
    "SSM-Only-Inlinepolicy-permissionset" = {
      description         = "Sample testing permissionset"
      managed_policy_arns = []
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
    },
  }
}

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
  default = {
    "123xxxxx1" = {
      users = {
        girishcodealchemy = { username = "girishcodealchemy", permissionset = ["SSM-testing-permissionset"] }
      }
      groups = {
        L1devopsgroup = { groupname = "L1-devops-group", permissionset = ["SSM-testing-permissionset", "SSM-Admin-permissionset", "SSM-Only-Managed-permissionset", "SSM-Only-Inlinepolicy-permissionset"] }
      }
    },
    "123xxxxx2" = {
      users = {
        girishcodealchemy = { username = "girishcodealchemy", permissionset = ["SSM-testing-permissionset"] }
      }
      groups = {
        L1devopsgroup = { groupname = "L1-devops-group", permissionset = ["SSM-testing-permissionset"] },
        L1AdminGroup  = { groupname = "L1-Admin-group", permissionset = ["SSM-testing-permissionset", "SSM-Admin-permissionset", "SSM-Only-Managed-permissionset", "SSM-Only-Inlinepolicy-permissionset"] }
      }
    }
  }
}
