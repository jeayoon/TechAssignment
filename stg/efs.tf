#--------------------------------------------------------------
# EFS
#--------------------------------------------------------------
resource "aws_efs_file_system" "main" {
  creation_token                  = "my-efs"
  provisioned_throughput_in_mibps = "50"
  throughput_mode                 = "provisioned"
 
  tags = {
    Name = "my-efs"
  }
}
 
#--------------------------------------------------------------
# EFS Mount Target
#--------------------------------------------------------------
resource "aws_efs_mount_target" "dmz_1" {
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = module.subnet.ids[var.subnet_names["dmz1"]]
  security_groups = [
    module.securityGroup.ids[var.sg_names["efs"]]
  ]
}
 
resource "aws_efs_mount_target" "dmz_2" {
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = module.subnet.ids[var.subnet_names["dmz2"]]
  security_groups = [
    module.securityGroup.ids[var.sg_names["efs"]]
  ]
}