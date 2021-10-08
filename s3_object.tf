resource "aws_s3_bucket_object" "appspec" {
  bucket = data.aws_s3_bucket.pipeline_config_bucket.bucket
  key    = "${var.environment}/${var.service}/appspec.json"
  content = templatefile("templates/appspec.json", {
    containerName = var.container_name
    containerPort = var.container_port
    environment   = var.environment
  })
}
