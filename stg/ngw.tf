#--------------------------------------------------------------
# Nat gateway
#--------------------------------------------------------------
resource "aws_eip" "natgw" {
  vpc = true

  tags = {
    Name = "natgw-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = module.subnet.ids[var.subnet_names["pub1"]]

  tags = {
    Name = "natgw"
  }

  depends_on = [aws_internet_gateway.main]
}