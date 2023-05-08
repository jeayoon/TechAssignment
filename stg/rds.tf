#--------------------------------------------------------------
# Prameter Group
#--------------------------------------------------------------
resource "aws_db_parameter_group" "main" {
  name        = "my-parameter-group"
  family      = "mysql5.7"
  description = "for RDS"
}
 
#--------------------------------------------------------------
# Subnet Group
#--------------------------------------------------------------
resource "aws_db_subnet_group" "main" {
  name        = "my-db-sb-group"
  description = "for RDS"
  subnet_ids = [
    module.subnet.ids[var.subnet_names["priv1"]],
    module.subnet.ids[var.subnet_names["priv2"]]
  ]
}
 
#--------------------------------------------------------------
# DB Instance
#--------------------------------------------------------------
resource "aws_db_instance" "rds" {
  identifier                = "my-db01"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  storage_type              = "gp2"
  allocated_storage         = "50"
  max_allocated_storage     = "100"
  username                  = "root"
  password                  = "password"
  final_snapshot_identifier = "fargate-efs-db01-final"
  db_subnet_group_name      = aws_db_subnet_group.main.name
  parameter_group_name      = aws_db_parameter_group.main.name
  multi_az                  = false
  vpc_security_group_ids = [
    module.securityGroup.ids[var.sg_names["rds"]]
  ]
  backup_retention_period = "7"
  apply_immediately       = true
}