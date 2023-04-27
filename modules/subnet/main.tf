#--------------------------------------------------------------
# Variables
#--------------------------------------------------------------
variable "subnets" {}

#--------------------------------------------------------------
# Subnets Settings
#--------------------------------------------------------------
resource "aws_subnet" "main" {
    for_each = { for i in var.subnets : i.name => i }

    vpc_id = each.value.vpc_id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    tags = {
        Name = each.value.name
    }
}