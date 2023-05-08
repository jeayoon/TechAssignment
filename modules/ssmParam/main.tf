#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "ssmParam" {}

#--------------------------------------------------------------
# SSM Parameter
#--------------------------------------------------------------
resource "aws_ssm_parameter" "main" {
  for_each = { for i in var.ssmParam : i.name => i }

  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
}