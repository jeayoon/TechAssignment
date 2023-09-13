#--------------------------------------------------------------
# backend (tfstate)
#--------------------------------------------------------------
terraform {
  required_version = "~> 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket  = "" # s3 bucket name
    region  = "ap-northeast-1"
    key     = "fargate/terraform.tfstate"
    encrypt = true
  }
}

#--------------------------------------------------------------
# Provider
#--------------------------------------------------------------
provider "aws" {
  shared_credentials_files = var.shared_credentials
  region                   = var.region
}

##---------First Deploy---------
##VPC
resource "aws_vpc" "main" {
  cidr_block = var.cidr
  tags       = merge(var.tags, { "Name" = "tf_vpc" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "tf_igw" })
}


##Subnet
resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 0) // 10.0.0.0/24
  availability_zone = "${var.region}a"
  tags              = merge(var.tags, { "Name" = "prv_sub01_a" })
}
resource "aws_subnet" "private-c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 2) // 10.0.2.0/24
  availability_zone = "${var.region}c"
  tags              = merge(var.tags, { "Name" = "prv_sub02_c" })
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1) // 10.0.1.0/24
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { "Name" = "pub_sub01_a" })
}
resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 3) // 10.0.3.0/24
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { "Name" = "pub_sub02_c" })
}

## NAT

resource "aws_eip" "eip_1a" {
  vpc  = true
  tags = merge(var.tags, { "Name" = "nat_eip_1a" })
}


resource "aws_eip" "eip_1c" {
  vpc  = true
  tags = merge(var.tags, { "Name" = "nat_eip_1c" })
}
resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.eip_1a.id
  subnet_id     = aws_subnet.public-a.id
  depends_on    = [aws_internet_gateway.main]
  tags          = merge(var.tags, { "Name" = "nat_1a" })
}
resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.eip_1c.id
  subnet_id     = aws_subnet.public-c.id
  depends_on    = [aws_internet_gateway.main]
  tags          = merge(var.tags, { "Name" = "nat-1c" })
}


## Route Table ALB
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "rt_alb" })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.public-c.id
  route_table_id = aws_route_table.public.id
}

## Route Table Private 1a, 1c
resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "rt_nat_1a" })
}

resource "aws_route" "private-a" {
  route_table_id         = aws_route_table.private-a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1a.id
}
resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private-a.id
}

resource "aws_route_table" "private-c" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "rt_nat_1c" })
}

resource "aws_route" "private-c" {
  route_table_id         = aws_route_table.private-c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1c.id
}
resource "aws_route_table_association" "private-c" {
  subnet_id      = aws_subnet.private-c.id
  route_table_id = aws_route_table.private-c.id
}

## Security group ECS
resource "aws_security_group" "app" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "tf-app-sg" })
}

resource "aws_security_group_rule" "allow_alb_sg_inbound" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "allow_every_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = ["0.0.0.0/0"]
}

## Security Group ALB
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "tf-alb-sg" })
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_app_sg_outbound" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
}

## ECR
resource "aws_ecr_repository" "main" {
  name                 = "ecr-${var.environment}"
  image_tag_mutability = "MUTABLE"
  tags                 = merge(var.tags, {})
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}

###---------Second Deploy---------
## ECS Clouster
resource "aws_ecs_cluster" "main" {
  name = "tf-custer"
  tags = merge(var.tags, {})
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]
}

## Cloud Watch Log Group
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/logs/terraform/nginx"
  retention_in_days = 1
}

## IAM
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ECS
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-task-def"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name" : "${var.environment}-container",
      "image" : "${var.container_image}",
      "cpu" : 256,
      "essential" : true,
      "memory" : 128,
      "portMappings" : [
        {
          "protocol" : "tcp",
          "containerPort" : var.container_port,
          "hostPort" : var.container_port
        }
      ],
      "LogConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/logs/terraform/nginx",
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "terraform"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name                               = "${var.environment}-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.app.id]
    subnets          = [aws_subnet.private-a.id, aws_subnet.private-c.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "${var.environment}-container"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
  depends_on = [aws_lb.main]
}

# alb
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-a.id, aws_subnet.public-c.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name        = "${var.environment}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# ## Autoscaling
# resource "aws_appautoscaling_target" "ecs_target" {
#   max_capacity       = 4
#   min_capacity       = 1
#   resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }

# resource "aws_appautoscaling_policy" "ecs_policy_alb" {
#   name               = "alb-req-autoscaling"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ALBRequestCountPerTarget"
#       resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.main.arn_suffix}"
#     }
#     target_value       = 4000
#     scale_in_cooldown  = 300
#     scale_out_cooldown = 10
#   }
# }
