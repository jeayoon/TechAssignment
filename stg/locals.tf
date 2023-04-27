#--------------------------------------------------------------
# Locals Settings
#--------------------------------------------------------------
# Input Mapping
locals {
  subnets = {
    pub1 = {
      az         = "${var.region}a"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["pub1"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 10) #10.0.10.0/24
    }
    pub2 = {
      az         = "${var.region}c"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["pub2"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 11) #10.0.11.0/24
    }
    dmz1 = {
      az         = "${var.region}a"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["dmz1"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 20) #10.0.20.0/24
    }
    dmz2 = {
      az         = "${var.region}c"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["dmz2"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 21) #10.0.21.0/24
    }
    priv1 = {
      az         = "${var.region}a"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["priv1"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 30) #10.0.30.0/24
    }
    priv2 = {
      az         = "${var.region}c"
      vpc_id     = module.vpc.id
      name       = var.subnet_names["priv2"]
      cidr_block = cidrsubnet(module.vpc.cidr_block, 8, 31) #10.0.31.0/24
    }
  }

  routeTables = {
    pub1 = {
      vpc_id = module.vpc.id
      name   = var.rt_names["pub1"]
    }
    dmz1 = {
      vpc_id = module.vpc.id
      name   = var.rt_names["dmz1"]
    }
    priv1 = {
      vpc_id = module.vpc.id
      name   = var.rt_names["priv1"]
    }
  }

  routeAssoc = {
    pub1 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["pub1"]]
      rtTable_id = module.routeTable.ids[var.rt_names["pub1"]]
    }
    pub2 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["pub2"]]
      rtTable_id = module.routeTable.ids[var.rt_names["pub1"]]
    }
    dmz1 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["dmz1"]]
      rtTable_id = module.routeTable.ids[var.rt_names["dmz1"]]
    }
    dmz2 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["dmz2"]]
      rtTable_id = module.routeTable.ids[var.rt_names["dmz1"]]
    }
    priv1 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["priv1"]]
      rtTable_id = module.routeTable.ids[var.rt_names["priv1"]]
    }
    priv2 = {
      sbnet_id   = module.subnet.ids[var.subnet_names["priv2"]]
      rtTable_id = module.routeTable.ids[var.rt_names["priv1"]]
    }
  }

  sg = {
    alb = {
      name   = var.sg_names["alb"]
      vpc_id = module.vpc.id
    }
    efs = {
      name   = var.sg_names["efs"]
      vpc_id = module.vpc.id
    }
    rds = {
      name   = var.sg_names["rds"]
      vpc_id = module.vpc.id
    }
    fargate = {
      name   = var.sg_names["fargate"]
      vpc_id = module.vpc.id
    }
  }

  sg_rules = {
    httpToALB = {
      security_group_id        = module.securityGroup.ids[var.sg_names["alb"]]
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "From HTTP to ALB"
    }
    albToFargate = {
      security_group_id        = module.securityGroup.ids[var.sg_names["fargate"]]
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = module.securityGroup.ids[var.sg_names["alb"]]
      description              = "From ALB to Fargate"
    }
    fargateToEfs = {
      security_group_id        = module.securityGroup.ids[var.sg_names["efs"]]
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = module.securityGroup.ids[var.sg_names["fargate"]]
      description              = "From Fargate to EFS"      
    }
    fargateToRDS = {
      security_group_id        = module.securityGroup.ids[var.sg_names["rds"]]
      type                     = "ingress"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = module.securityGroup.ids[var.sg_names["fargate"]]
      description              = "From Fargate to RDS"      
    }
    albAll = {
      security_group_id        = module.securityGroup.ids[var.sg_names["alb"]]
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "AllOutbound ALB"      
    }
    fargateAll = {
      security_group_id        = module.securityGroup.ids[var.sg_names["fargate"]]
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "AllOutbound Fargate"      
    }
    efsAll = {
      security_group_id        = module.securityGroup.ids[var.sg_names["efs"]]
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "AllOutbound EFS"      
    }
    rdsAll = {
      security_group_id        = module.securityGroup.ids[var.sg_names["rds"]]
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "AllOutbound RDS"      
    }
  }

}

# Output Mapping
locals {

}
