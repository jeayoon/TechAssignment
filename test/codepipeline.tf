##-------------
# Code Pipeline
##-------------

#--------------------------------------------------------------
# S3 bucket Setting
#--------------------------------------------------------------
resource "aws_s3_bucket" "artifact" {
  bucket = local.artifact_bucket_name

  tags = merge(var.tags, { "Name" = "myArtifact" })
}

# Code Commit
resource "aws_codecommit_repository" "main" {
  repository_name = local.codecommit_name
}

# Code Build
resource "aws_iam_role" "codebuild-role" {
  name = "${var.environment}-codebuildRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild-policy" {
  role = aws_iam_role.codebuild-role.name
  policy = templatefile(
    "./files/codebuild_policy.json.tpl", {
      region           = var.region
      account_id       = local.account_id
      codebuild_name   = local.codebuild_name
      bucket_name      = local.artifact_bucket_name
      param_store_name = var.param_store_name
    }
  )
}

resource "aws_codebuild_project" "main" {
  name         = local.codebuild_name
  service_role = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.main.clone_url_http
  }

  source_version = "main"

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = var.ecr_name
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = local.container_name
    }
  }
}

# Code Deploy
resource "aws_iam_role" "codedeploy-role" {
  name = "${var.environment}-codedeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_role_policy" "codedeploy-policy" {
#   role = aws_iam_role.codedeploy-role.name
#   policy = templatefile(
#     "./files/codedeploy_policy.json.tpl", {
#       region                              = var.region
#       account_id                          = local.account_id
#       execution_role_arn                  = aws_iam_role.ecs_task_execution_role.arn
#       aws_ecs_service_id                  = aws_ecs_service.main.id
#       aws_codedeploy_deployment_group_arn = aws_codedeploy_deployment_group.main.arn
#       aws_codedeploy_app_arn              = aws_codedeploy_app.main.arn
#     }
#   )
# }

resource "aws_iam_role_policy" "codedeploy-policy" {
  role   = aws_iam_role.codedeploy-role.name
  policy = templatefile("./files/codedeploy_policy.json.tpl", {})
}

# resource "aws_iam_role_policy_attachment" "codedeploy-attachment" {
#   role       = aws_iam_role.codedeploy-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECSLimited"
# }


resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = local.codedeploy_name
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.environment}-codeDeployGroup"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy-role.arn

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      # test_traffic_route {
      #   listener_arns = [aws_lb_listener.test.arn]
      # }

      target_group {
        name = aws_lb_target_group.main.name
      }

      target_group {
        name = aws_lb_target_group.main2.name
      }
    }
  }

}

# Code Pepiline
resource "aws_iam_role" "codepipeline-role" {
  name = "${var.environment}-codepipelineRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline-policy" {
  role   = aws_iam_role.codepipeline-role.name
  policy = templatefile("./files/codepipeline_policy.json.tpl", {})
}


resource "aws_codepipeline" "pipeline" {
  name     = "${var.environment}-pipelineFargate"
  role_arn = aws_iam_role.codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"
  }
  # SOURCE
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = local.codecommit_name
        BranchName     = "main"
      }
    }
  }
  # BUILD
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = local.codebuild_name
      }
    }
  }
  # DEPLOY
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ApplicationName                = aws_codedeploy_app.main.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.main.deployment_group_name
        AppSpecTemplateArtifact        = "source_output"
        AppSpecTemplatePath            = "appspec.yaml"
        TaskDefinitionTemplateArtifact = "source_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
    }
  }
}
