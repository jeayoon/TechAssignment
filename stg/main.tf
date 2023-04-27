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
# Internet Gateway
#--------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.id

  tags = {
    Name = "igw"
  }
}

#--------------------------------------------------------------
# Nat gateway
#--------------------------------------------------------------
resource "aws_eip" "natgw" {
  vpc = true

  tags = {
    Name = "natgw-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = module.subnet.ids[var.subnet_names["pub1"]]

  tags = {
    Name = "natgw"
  }

  depends_on = [aws_internet_gateway.main]
}

#--------------------------------------------------------------
# Route
#--------------------------------------------------------------
resource "aws_route" "public" {
  route_table_id         = module.routeTable.ids[var.rt_names["pub1"]]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
  depends_on             = [module.routeTable]
}

resource "aws_route" "dmz" {
  route_table_id         = module.routeTable.ids[var.rt_names["dmz1"]]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
  depends_on             = [module.routeTable]
}

