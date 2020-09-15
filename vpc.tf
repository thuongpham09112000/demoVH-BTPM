resource "aws_vpc" "LabVpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "LabVpc"
  }
}

resource "aws_vpc_dhcp_options" "LabDhcp" {
  domain_name         = "lab.local"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "LabDhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "LabDhcp" {
  vpc_id          = aws_vpc.LabVpc.id
  dhcp_options_id = aws_vpc_dhcp_options.LabDhcp.id
}

resource "aws_security_group" "LabSecGrpPub" {
  name        = "LabSecGrpPub"
  description = "Allow inbound Lab traffic, SSH taffic from Internet  and all outbound traffic"
  vpc_id      = aws_vpc.LabVpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LabSecGrpPub"
  }
}

resource "aws_security_group" "LabSecGrpPrv" {
  name        = "LabSecGrpPrv"
  description = "Allow only inbound Lab traffic and all outbound traffic"
  vpc_id      = aws_vpc.LabVpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LabSecGrpPrv"
  }
}

resource "aws_subnet" "LabNetPubA" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.AWS_REGION, "a")

  tags = {
    Name = "LabNetPubA"
  }
}

resource "aws_subnet" "LabNetPubB" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.AWS_REGION, "b")

  tags = {
    Name = "LabNetPubB"
  }
}

resource "aws_subnet" "LabNetPubC" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.30.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.AWS_REGION, "c")

  tags = {
    Name = "LabNetPubC"
  }
}

resource "aws_subnet" "LabNetPrvA" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, "a")

  tags = {
    Name = "LabNetPrvA"
  }
}

resource "aws_subnet" "LabNetPrvB" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.21.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, "b")

  tags = {
    Name = "LabNetPrvB"
  }
}

resource "aws_subnet" "LabNetPrvC" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.31.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, "c")

  tags = {
    Name = "LabNetPrvC"
  }
}

resource "aws_internet_gateway" "LabInetGw" {
  vpc_id = aws_vpc.LabVpc.id

  tags = {
    Name = "LabInetGw"
  }
}

resource "aws_eip" "LabEipNatGwPubA" {
  vpc = true

  tags = {
    Name = "LabEipNatGwPubA"
  }
}

resource "aws_nat_gateway" "LabNatGwPubA" {
  allocation_id = aws_eip.LabEipNatGwPubA.id
  subnet_id     = aws_subnet.LabNetPubA.id

  tags = {
    Name = "LabNatGwPubA"
  }
}

resource "aws_eip" "LabEipNatGwPubB" {
  vpc = true

  tags = {
    Name = "LabEipNatGwPubB"
  }
}

resource "aws_nat_gateway" "LabNatGwPubB" {
  allocation_id = aws_eip.LabEipNatGwPubB.id
  subnet_id     = aws_subnet.LabNetPubB.id

  tags = {
    Name = "LabNatGwPubB"
  }
}

resource "aws_eip" "LabEipNatGwPubC" {
  vpc = true

  tags = {
    Name = "LabEipNatGwPubC"
  }
}

resource "aws_nat_gateway" "LabNatGwPubC" {
  allocation_id = aws_eip.LabEipNatGwPubC.id
  subnet_id     = aws_subnet.LabNetPubC.id

  tags = {
    Name = "LabNatGwPubC"
  }
}

resource "aws_route_table" "LabRouteTablePubA" {
  vpc_id = aws_vpc.LabVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.LabInetGw.id
  }

  tags = {
    Name = "LabRouteTablePubA"
  }
}

resource "aws_route_table_association" "LabRouteTablePubA" {
  subnet_id      = aws_subnet.LabNetPubA.id
  route_table_id = aws_route_table.LabRouteTablePubA.id
}

resource "aws_route_table" "LabRouteTablePubB" {
  vpc_id = aws_vpc.LabVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.LabInetGw.id
  }

  tags = {
    Name = "LabRouteTablePubB"
  }
}

resource "aws_route_table_association" "LabRouteTablePubB" {
  subnet_id      = aws_subnet.LabNetPubB.id
  route_table_id = aws_route_table.LabRouteTablePubB.id
}

resource "aws_route_table" "LabRouteTablePubC" {
  vpc_id = aws_vpc.LabVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.LabInetGw.id
  }

  tags = {
    Name = "LabRouteTablePubC"
  }
}

resource "aws_route_table_association" "LabRouteTablePubC" {
  subnet_id      = aws_subnet.LabNetPubC.id
  route_table_id = aws_route_table.LabRouteTablePubC.id
}

resource "aws_route_table" "LabRouteTablePrvA" {
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPubA.id
  }

  tags = {
    Name = "LabRouteTablePrvA"
  }
}

resource "aws_route_table_association" "LabRouteTablePrvA" {
  subnet_id      = aws_subnet.LabNetPrvA.id
  route_table_id = aws_route_table.LabRouteTablePrvA.id
}

resource "aws_route_table" "LabRouteTablePrvB" {
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPubB.id
  }

  tags = {
    Name = "LabRouteTablePrvB"
  }
}

resource "aws_route_table_association" "LabRouteTablePrvB" {
  subnet_id      = aws_subnet.LabNetPrvB.id
  route_table_id = aws_route_table.LabRouteTablePrvB.id
}

resource "aws_route_table" "LabRouteTablePrvC" {
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPubC.id
  }

  tags = {
    Name = "LabRouteTablePrvC"
  }
}

resource "aws_route_table_association" "LabRouteTablePrvC" {
  subnet_id      = aws_subnet.LabNetPrvC.id
  route_table_id = aws_route_table.LabRouteTablePrvC.id
}

