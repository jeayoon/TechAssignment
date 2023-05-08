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