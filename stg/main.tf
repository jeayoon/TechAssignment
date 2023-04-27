#--------------------------------------------------------------
# backend (tfstate)
#--------------------------------------------------------------
terraform {
  required_version = "~> 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "jy-bucket-tfstate"      # s3 bucket name
    region = "ap-northeast-1"
    key = "staging/terraform.tfstate"
    encrypt = true
  }
}

#--------------------------------------------------------------
# Provider Settings
#--------------------------------------------------------------
provider "aws" {
    shared_credentials_file = var.shared_credentials_file
    region                  = var.region
}

# #--------------------------------------------------------------
# # Module VPC Settings
# #--------------------------------------------------------------
# module "module_vpc" {
#     source = "../modules/vpc"

#     env    = var.env
#     cidr   = var.root_segment
# }