variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "shared_credentials" {
  type    = list(string)
  default = ["~/.aws/credentials"]
}
variable "environment" {
  type    = string
  default = "test"
}
variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.0.0/24"]
  description = "List of public subnets"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "List of private subnets"
}
variable "availability_zones" {
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  description = "List of availability zones"
}
variable "container_port" {
  type        = number
  default     = 80
  description = "Ingres and egress port of the container"
}

variable "container_image" {
    type = string
    default = "650309928311.dkr.ecr.ap-northeast-1.amazonaws.com/ecr-test:latest"
  description = "Docker image to be launched"
}

# variable "aws_alb_target_group_arn" {
#   description = "ARN of the alb target group"
# }

# variable "service_desired_count" {
#   description = "Number of services running in parallel"
# }

# variable "container_environment" {
#   description = "The container environmnent variables"
#   type        = list
#   default = []
# }

# variable "container_secrets" {
#   description = "The container secret environmnent variables"
#   type        = list
#     default = []
# }

# variable "container_secrets_arns" {
#   description = "ARN for secrets"
# }