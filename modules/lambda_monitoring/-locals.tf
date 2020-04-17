locals {
  namespace = var.namespace
  metrics-memory-name = "Memory"
  metrics-namespace = "${var.project}/${local.namespace}"

  tags = {
    Environment = var.environment,
    Project = var.project,
    Module = local.namespace
  }
}