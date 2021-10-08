data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

data "aws_lb" "selected" {
  name = "${var.service}-${var.environment}"
}

data "aws_ecs_service" "main" {
  service_name = var.service
  cluster_arn  = data.aws_ecs_cluster.cluster.arn
}

data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.selected.arn
  port              = 80
}

data "aws_lb_listener" "https_test" {
  load_balancer_arn = data.aws_lb.selected.arn
  port              = 8080
}

data "aws_lb_target_group" "blue" {
  name = "${var.environment}-${var.service}-b"
}

data "aws_lb_target_group" "green" {
  name = "${var.environment}-${var.service}-g"
}

data "aws_s3_bucket" "pipeline_config_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-pipeline-config-bucket"
}

data "aws_s3_bucket" "pipeline_artifacts_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-pipeline-artifacts-bucket"
}

data "aws_ecr_repository" "service" {
  name = var.service
}

data "aws_iam_role" "codedeploy" {
  name = var.codedeploy_iam
}

data "aws_lambda_function" "failure_function" {
  function_name = var.failure_notification_lambda_name
}
