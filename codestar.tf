resource "aws_codestarnotifications_notification_rule" "pipeline_failure" {
  detail_type = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-pipeline-execution-failed",
    "codepipeline-pipeline-pipeline-execution-canceled",
  ]
  name     = "${var.environment}-${var.service}-codedeploy-failure-notification"
  resource = aws_codepipeline.codepipeline.arn

  target {
    address = aws_sns_topic.pipeline_failure.arn
    type    = "SNS"
  }
}
