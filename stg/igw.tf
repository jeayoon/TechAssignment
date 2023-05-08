#--------------------------------------------------------------
# Internet Gateway
#--------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = module.vpc.id

  tags = {
    Name = "igw"
  }
}