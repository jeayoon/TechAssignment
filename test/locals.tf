data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  artifact_bucket_name = "${var.environment}-myartifact3212"
  codebuild_name       = "${var.environment}-myCodeBuild"
  codedeploy_name      = "${var.environment}-CodeDeploy"
  codecommit_name      = "${var.environment}-myCodeCommit"
  container_name       = "${var.environment}-container"
}
