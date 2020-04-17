locals {
  namespace = replace(var.queue["name"], "-queue", "")
}