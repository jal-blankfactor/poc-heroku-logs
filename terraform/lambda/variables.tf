variable "env_level" {
  type = string
}

variable "env_name" {
  type = string
}

variable "short_name" {
  type = string
}

variable "display_name" {
  type = string
}

variable "app_dir" {
  type = string
}

variable "env_vars" {
  type    = map(string)
  default = {}
}

variable "policy_arns" {
  type    = list(string)
  default = []
}

variable "runtime" {
  type = string
}
