resource "aws_sns_topic" "alarms" {
  name = "${local.namespace}-alarms"
  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "time" {
  alarm_name          = "${local.namespace}-execution-time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = var.lambda["timeout"]
  statistic           = "Maximum"
  threshold           = var.lambda["timeout"] * 1000
  alarm_description   = "Timeout"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alarms.arn,
  ]

  dimensions = {
    FunctionName = var.lambda["function_name"]
  }
  tags = local.tags
}

resource "aws_cloudwatch_log_metric_filter" "memory" {
  name           = "${local.namespace}-memory"
  log_group_name = var.log_group_name

  // REPORT RequestId: 8e3ce248-8b0d-4f48-b238-1f2862e675ed Duration: 1340.44 ms Billed Duration: 1400 ms Memory Size: 512 MB Max Memory Used: 43 MB Init Duration: 2248.97 ms
  pattern = "[report_name=\"REPORT\", request_id_name=\"RequestId:\", request_id_value, duration_name=\"Duration:\", duration_value, duration_unit=\"ms\", billed_duration_name_1=\"Billed\", bill_duration_name_2=\"Duration:\", billed_duration_value, billed_duration_unit=\"ms\", memory_size_name_1=\"Memory\", memory_size_name_2=\"Size:\", memory_size_value, memory_size_unit=\"MB\", max_memory_used_name_1=\"Max\", max_memory_used_name_2=\"Memory\", max_memory_used_name_3=\"Used:\", max_memory_used_value, max_memory_used_unit=\"MB\", ...]"

  metric_transformation {
    name      = local.metrics-memory-name
    namespace = local.metrics-namespace
    value     = "$max_memory_used_value"
  }
}

resource "aws_cloudwatch_metric_alarm" "memory" {
  depends_on = [
    aws_cloudwatch_log_metric_filter.memory,
  ]

  alarm_name          = "${local.namespace}-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = local.metrics-memory-name
  namespace           = local.metrics-namespace
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.lambda["memory_size"]
  alarm_description   = "Max Memory Exceeded"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alarms.arn,
  ]
  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "errors" {
  alarm_name          = "${local.namespace}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Execution Errors"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alarms.arn,
  ]

  dimensions = {
    FunctionName = var.lambda["function_name"]
  }
  tags = local.tags
}