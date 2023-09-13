variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "tags" {
  type = map(string)
  default = {
    env = "fargate-dev"
  }
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
variable "container_port" {
  type        = number
  default     = 80
  description = "Ingres and egress port of the container"
}
variable "container_image" {
  type        = string
  default     = "253854447487.dkr.ecr.ap-northeast-1.amazonaws.com/ecr-test:latest" ## ECR Image URL : 123456789012.dkr.ecr.$REGION_NAME.amazonaws.com/ecr-test:latest
  description = "Docker image to be launched"
}
