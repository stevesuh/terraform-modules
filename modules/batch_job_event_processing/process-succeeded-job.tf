resource "aws_cloudwatch_event_rule" "batch_job_succeeded" {
  name        = "${local.namespace}-batch-job-succeeded"
  description = "${title(var.project)} Batch job succeeded"

  event_pattern = jsonencode({
    "detail-type": [
      "Batch Job State Change"
    ],
    "source": [
      "aws.batch"
    ],
    "detail": {
      "jobQueue": [var.queue["arn"]],
      "status": [
        "SUCCEEDED"
      ]
    }
  })
}

output "batch_job_succeeded_map" {
  description = "batch_job_succeeded CW event rule"
  value = {
    "name" = aws_cloudwatch_event_rule.batch_job_succeeded.name
    "arn" = aws_cloudwatch_event_rule.batch_job_succeeded.arn
  }
}

resource "aws_cloudwatch_event_target" "succeeded_job" {
  rule = aws_cloudwatch_event_rule.batch_job_succeeded.name
  arn = var.lambda["arn"]
}

resource "aws_lambda_permission" "succeeded_job" {
    action = "lambda:InvokeFunction"
    function_name = var.lambda["function_name"]
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.batch_job_succeeded.arn
}
