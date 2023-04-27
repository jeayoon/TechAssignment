#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "routeAssoc" {}

#--------------------------------------------------------------
# Route Association
#--------------------------------------------------------------
resource "aws_route_table_association" "main" {
  for_each = var.routeAssoc
  
  subnet_id      = each.value.sbnet_id
  route_table_id = each.value.rtTable_id
}
