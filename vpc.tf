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
  domain_name         = "lab"
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

resource "aws_subnet" "LabNetPrvA" {
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, "a")

  tags = {
    Name = "LabNetPrvA"
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

