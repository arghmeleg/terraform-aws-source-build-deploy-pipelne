variable "environment" {
  default = "dev"
}
variable "project" {}
variable "service" {}
variable "region_abbr" {
  default = "uw2"
}
variable "container_name" {}
variable "container_port" {}
variable "cluster_name" {}
variable "deployment_app_name" {
  default = "ecs"
}
variable "failure_notification_lambda_name" {
  default = "dev-deployment-failure"
}
variable "codedeploy_iam" {
  default = "global-codedeploy-role"
}
variable "deployment_type" {
  default = "ecs"
}
variable "github_repository_id" {}
variable "github_branch" {
  default = "develop"
}
variable "github_codestar_connection" {}
