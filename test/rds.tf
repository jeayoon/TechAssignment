##---------------
#RDS
##---------------

##Subnet
resource "aws_subnet" "private-a2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 4) // 10.0.4.0/24
  availability_zone = "${var.region}a"
  tags              = merge(var.tags, { "Name" = "prv_sub03_a" })
}
resource "aws_subnet" "private-c2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 6) // 10.0.6.0/24
  availability_zone = "${var.region}c"
  tags              = merge(var.tags, { "Name" = "prv_sub04_c" })
}

##RouteTable
## Route Table Private 2a, 2c
resource "aws_route_table" "rds" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "rt_rds_1" })
}

resource "aws_route_table_association" "rds1" {
  subnet_id      = aws_subnet.private-a2.id
  route_table_id = aws_route_table.rds.id
}
resource "aws_route_table_association" "rds2" {
  subnet_id      = aws_subnet.private-c2.id
  route_table_id = aws_route_table.rds.id
}

##SG
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "tf-rds-sg" })
}

resource "aws_security_group_rule" "from_fargate_to_rds" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.app.id
  description              = "from_fargate_to_rds"
}

resource "aws_security_group_rule" "from_elasticserver_to_rds" {
  security_group_id        = aws_security_group.rds.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.elastic.id
  description              = "from_elasticserver_to_rds"
}

resource "aws_security_group_rule" "egress_rds" {
  security_group_id = aws_security_group.rds.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound ALL"
}

# Elastic Cache SG
resource "aws_security_group" "elc" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { "Name" = "tf-elc-sg" })
}

resource "aws_security_group_rule" "from_elasticserver_to_elc" {
  security_group_id        = aws_security_group.elc.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 6379
  to_port                  = 6379
  source_security_group_id = aws_security_group.elastic.id
  description              = "from_elasticserver_to_elc"
}

resource "aws_security_group_rule" "egress_elc" {
  security_group_id = aws_security_group.elc.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Outbound ALL"
}


#####
# RDS
#####

####################
# Parameter Group
####################
resource "aws_db_parameter_group" "rds" {
  name        = "${var.environment}-rds-pg"
  family      = "mysql5.7"
  description = "for RDS"
}

####################
# Subnet Group
####################
resource "aws_db_subnet_group" "rds" {
  name        = "${var.environment}-rds-subg"
  description = "for RDS"
  subnet_ids = [
    aws_subnet.private-a2.id,
    aws_subnet.private-c2.id
  ]
}

####################
# Instance
####################
resource "aws_db_instance" "rds" {
  identifier                = "${var.environment}-rds-mysql"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  storage_type              = "gp2"
  allocated_storage         = "50"
  max_allocated_storage     = "100"
  username                  = "root"
  password                  = "password"
  final_snapshot_identifier = "fargate-efs-db01-final"
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  parameter_group_name      = aws_db_parameter_group.rds.name
  multi_az                  = true
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
  backup_retention_period = "7"
  apply_immediately       = true

  lifecycle {
    ignore_changes = [password]
  }
}
