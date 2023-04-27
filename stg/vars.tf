#--------------------------------------------------------------
# Variable Settings
#--------------------------------------------------------------
#AWS Settings
variable "region" {
  type    = string
  default = "ap-northeast-1"
}
variable "shared_credentials" {
  type    = list(string)
  default = ["~/.aws/credentials"]
}
variable "env" {
  type    = string
  default = "stg"
}

#IP Settings
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "subnet_names" {
  type = map(string)
  default = {
    "pub1"  = "sb-pub1"
    "pub2"  = "sb-pub2"
    "dmz1"  = "sb-dmz1"
    "dmz2"  = "sb-dmz2"
    "priv1" = "sb-priv1"
    "priv2" = "sb-priv2"
  }
}

variable "rt_names" {
  type = map(string)
  default = {
    "pub1"  = "route-pub1"
    "dmz1"  = "route-dmz1"
    "priv1" = "route-priv1"
  }
}

variable "sg_names" {
  type = map(string)
  default = {
    "alb"     = "alb-sg"
    "efs"     = "efs-sg"
    "rds"     = "rds-sg"
    "fargate" = "fargate-sg"
  }
}

