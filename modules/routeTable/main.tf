#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "routeTables" {}

#--------------------------------------------------------------
# Route table
#--------------------------------------------------------------
resource "aws_route_table" "main" {
  for_each = { for i in var.routeTables : i.name => i }

  vpc_id = each.value.vpc_id
  tags = {
    Name = each.value.name
  }
}
