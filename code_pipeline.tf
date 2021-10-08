resource "aws_codepipeline" "codepipeline" {
  name     = "${var.environment}-${var.service}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.pipeline_artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "S3SourceBundle"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["s3_bundle_artifacts"]

      configuration = {
        S3Bucket             = data.aws_s3_bucket.pipeline_config_bucket.bucket
        S3ObjectKey          = "${var.environment}/${var.service}/bundle.zip"
        PollForSourceChanges = "false"
      }
    }

    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_artifacts"]

      configuration = {
        ConnectionArn    = var.github_codestar_connection
        FullRepositoryId = var.github_repository_id
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildImage"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_artifacts"]
      output_artifacts = ["build_artifact"]
      version          = "1"

      configuration = {
        ProjectName = "${var.environment}-${var.region_abbr}-${var.project}-${var.service}-build"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "ECSGreenBlueDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["s3_bundle_artifacts", "build_artifact"]
      version         = "1"

      configuration = {
        ApplicationName                = var.deployment_app_name
        DeploymentGroupName            = "${var.environment}-${var.service}"
        TaskDefinitionTemplateArtifact = "s3_bundle_artifacts"
        TaskDefinitionTemplatePath     = "task_def.json"
        AppSpecTemplateArtifact        = "s3_bundle_artifacts"
        AppSpecTemplatePath            = "appspec.json"
        Image1ArtifactName             = "build_artifact"
        Image1ContainerName            = "IMAGE_NAME"
      }
    }
  }

  depends_on = [
    aws_codedeploy_deployment_group.main
  ]
}
