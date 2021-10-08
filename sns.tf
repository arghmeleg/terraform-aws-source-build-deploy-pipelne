resource "aws_sns_topic" "pipeline_failure" {
  name = "${var.environment}-${var.service}-pipeline-failure"
}

resource "aws_sns_topic_subscription" "pipeline_failure" {
  topic_arn = aws_sns_topic.pipeline_failure.arn
  protocol  = "lambda"
  endpoint  = data.aws_lambda_function.failure_function.arn
}

data "aws_iam_policy_document" "pipeline_failure_policy" {
  statement {
    sid    = "codestar-notification"
    effect = "Allow"
    resources = [
      aws_sns_topic.pipeline_failure.arn
    ]

    principals {
      identifiers = [
        "codestar-notifications.amazonaws.com"
      ]
      type = "Service"
    }
    actions = [
      "SNS:Publish"
    ]
  }
}

resource "aws_sns_topic_policy" "pipeline_failure" {
  arn    = aws_sns_topic.pipeline_failure.arn
  policy = data.aws_iam_policy_document.pipeline_failure_policy.json
}
