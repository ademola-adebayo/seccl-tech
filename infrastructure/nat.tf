resource "aws_eip" "nat-eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.public_subnet.id
  depends_on  = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }  

  tags = {
    Name = "levelup-private"
  }
}


#route associations private
resource "aws_route_table_association" "private-rta" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private-rt.id
}