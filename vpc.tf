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

resource "aws_internet_gateway" "LabInetGw" {
  vpc_id = aws_vpc.LabVpc.id

  tags = {
    Name = "LabInetGw"
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

resource "aws_subnet" "LabNetPub" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.${count.index + 1}0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.AWS_REGION, var.availability_zones[count.index % length(var.availability_zones)])

  tags = {
    Name = "LabNetPub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_subnet" "LabNetPrv" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.${count.index + 1}1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, var.availability_zones[count.index % length(var.availability_zones)])

  tags = {
    Name = "LabNetPub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_eip" "LabEipNatGwPub" {
  count = length(var.availability_zones)
  vpc   = true

  tags = {
    Name = "LabEipNatGwPub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_nat_gateway" "LabNatGwPub" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.LabEipNatGwPub[count.index].id
  subnet_id     = aws_subnet.LabNetPub[count.index].id

  tags = {
    Name = "LabNatGwPub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_route_table" "LabRouteTablePub" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.LabVpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.LabInetGw.id
  }

  tags = {
    Name = "LabRouteTablePub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_route_table_association" "LabRouteTablePub" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.LabNetPub[count.index].id
  route_table_id = aws_route_table.LabRouteTablePub[count.index].id
}

resource "aws_route_table" "LabRouteTablePrv" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPub[count.index].id
  }

  tags = {
    Name = "LabRouteTablePrv${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_route_table_association" "LabRouteTablePrv" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.LabNetPrv[count.index].id
  route_table_id = aws_route_table.LabRouteTablePrv[count.index].id
}
