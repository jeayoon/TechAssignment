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
    bucket  = "jy-bucket-tfstate" # s3 bucket name
    region  = "ap-northeast-1"
    key     = "staging/terraform.tfstate"
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

#--------------------------------------------------------------
# Module VPC
#--------------------------------------------------------------
module "vpc" {
  source = "../modules/vpc"

  env  = var.env
  cidr = var.vpc_cidr
}
#--------------------------------------------------------------
# Module Subnet
#--------------------------------------------------------------
module "subnet" {
  source = "../modules/subnet"

  subnets = local.subnets
}
#--------------------------------------------------------------
# Module Route table
#--------------------------------------------------------------
module "routeTable" {
  source = "../modules/routeTable"

  routeTables = local.routeTables
}

#--------------------------------------------------------------
# Module Route Association
#--------------------------------------------------------------
module "routeAssoc" {
  source = "../modules/routeAssoc"

  routeAssoc = local.routeAssoc
}

#--------------------------------------------------------------
# Module Security Group
#--------------------------------------------------------------
module "securityGroup" {
  source = "../modules/securityGroup"

  sg = local.sg
}

#--------------------------------------------------------------
# Module Security Group Rule
#--------------------------------------------------------------
module "securityGroupRules" {
  source = "../modules/securityGroup/rules"

  sg_rules = local.sg_rules
}

#--------------------------------------------------------------
# SSM Parameter
#--------------------------------------------------------------
module "ssmParam" {
  source = "../modules/ssmParam"

  ssmParam = local.ssmParam
}

