variable "environment" {
  type = string
  default = null
}

variable "project" {
  type = string
  default = null
}

variable "namespace" {
  type = string
  default = null
}

variable "lambda" {
  type = map(string)
  default = null
}

variable "log_group_name" {
  type = string
  default = null
}