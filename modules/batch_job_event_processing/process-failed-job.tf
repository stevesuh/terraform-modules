resource "aws_cloudwatch_event_rule" "batch_job_failed" {
  name        = "${local.namespace}-batch-job-failed"
  description = "${title(var.project)} Batch job failed"

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
        "FAILED"
      ]
    }
  })
}

output "batch_job_failed_map" {
  description = "batch_job_failed CW event rule"
  value = {
    "name" = aws_cloudwatch_event_rule.batch_job_failed.name
    "arn" = aws_cloudwatch_event_rule.batch_job_failed.arn
  }
}

resource "aws_sns_topic" "batch_job_failed" {
  name = "${local.namespace}-batch-job-failed"
  policy = jsonencode(
    {"Version": "2012-10-17",
      "Id":"__default_policy_ID",
      "Statement":[
        {
          Sid:"__default_statement_ID",
          Effect:"Allow",
          Principal:{"AWS":"*"},
          Action:["SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive"],
          Resource: "arn:aws:sns:${var.region}:${var.account_number}:${local.namespace}-batch-job-failed",
          Condition:{"StringEquals":{"AWS:SourceOwner": var.account_number
          }}
        },
        {
          Sid:"TrustCWEToPublishEventsToMyTopic",
          Effect:"Allow",
          Principal:{"Service":"events.amazonaws.com"},
          Action:"sns:Publish",
          Resource: "arn:aws:sns:${var.region}:${var.account_number}:${local.namespace}-batch-job-failed"
        }
      ]
    })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.batch_job_failed.name
  arn       = aws_sns_topic.batch_job_failed.arn
}

resource "aws_cloudwatch_event_target" "failed_job" {
  rule = aws_cloudwatch_event_rule.batch_job_failed.name
  arn = var.lambda["arn"]
}

resource "aws_lambda_permission" "failed_job" {
    action = "lambda:InvokeFunction"
    function_name = var.lambda["function_name"]
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.batch_job_failed.arn
}