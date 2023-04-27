#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "sg_rules" {}

#--------------------------------------------------------------
# Security Group Rules
#--------------------------------------------------------------
resource "aws_security_group_rule" "main" {
  for_each = var.sg_rules

  security_group_id        = each.value.security_group_id
  type                     = each.value.type
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = each.value.cidr_blocks
  source_security_group_id = each.value.source_security_group_id
  description              = each.value.description
}