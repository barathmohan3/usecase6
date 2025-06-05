variable "function_name" {
  type = string
}

variable "handler_file" {
  type = string
}

variable "handler_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "environment_vars" {
  type = map(string)
}