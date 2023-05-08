#--------------------------------------------------------------
# Cluster
#--------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

#--------------------------------------------------------------
# Task Definition
#--------------------------------------------------------------
resource "aws_ecs_task_definition" "main" {
  family                = "task-fargate-wordpress"
  container_definitions = file("./tasks/container_definitions.json")
  cpu                   = "256"
  memory                = "512"
  network_mode          = "awsvpc"
  execution_role_arn    = aws_iam_role.fargate_task_execution.arn

#   volume {
#     name = "my-efs"

#     efs_volume_configuration {
#       file_system_id = aws_efs_file_system.main.id
#       root_directory = "/"
#     }
#   }

  requires_compatibilities = [
    "FARGATE"
  ]
}


#--------------------------------------------------------------
# ECS
#--------------------------------------------------------------
resource "aws_ecs_service" "service" {
  name             = "my-ecs"
  cluster          = aws_ecs_cluster.main.arn
  task_definition  = aws_ecs_task_definition.main.arn
  desired_count    = 2
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "wordpress"
    container_port   = "80"
  }

  network_configuration {
    subnets = [
      module.subnet.ids[var.subnet_names["dmz1"]],
      module.subnet.ids[var.subnet_names["dmz2"]]
    ]
    security_groups = [
      module.securityGroup.ids[var.sg_names["fargate"]]
    ]
    assign_public_ip = false
  }
}

#--------------------------------------------------------------
# ECR
#--------------------------------------------------------------
resource "aws_ecr_repository" "main" {
  name                 = "my-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}