variable "environment" {
  type    = string
  default = null
}

variable "account_number" {
  type    = number
  default = null
}

variable "region" {
  type = string
  default = null
}

variable "project" {
  type    = string
  default = null
}

variable "queue" {
  type = map(string)
  default = null
}

variable "lambda" {
  type = map(string)
  default = null
}