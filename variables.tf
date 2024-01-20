variable "identity_store_ids" {
  description = "List of Identity Store IDs to search for users and groups."
  type        = list(string)
  default     = []

}

variable "ssoadmin_instance_arns" {
  description = "List of Identity Store Instance arns to search for users and groups."
  type        = list(string)
  default     = []

}

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

variable "sso_groups_configmap" {
  description = "This sets the configuration for SSO Users"
  type = map(object({
    display_name = string
    description  = string
    users        = list(string)
  }))
}

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
    error_message = "Both managed_policy_arns and inline_policy cannot be empty in sso_permissionsets_configmap."
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
}
