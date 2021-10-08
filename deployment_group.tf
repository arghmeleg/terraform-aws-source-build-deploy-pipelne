resource "aws_codedeploy_deployment_group" "main" {
  app_name               = var.deployment_app_name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.environment}-${var.service}"
  service_role_arn       = data.aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [data.aws_lb_listener.https.arn]
      }

      test_traffic_route {
        listener_arns = [data.aws_lb_listener.https_test.arn]
      }

      target_group {
        name = data.aws_lb_target_group.blue.name
      }

      target_group {
        name = data.aws_lb_target_group.green.name
      }

    }
  }
}
