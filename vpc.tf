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

resource "aws_subnet" "LabNetPrv1" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.${count.index + 1}1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, var.availability_zones[count.index % length(var.availability_zones)])

  tags = {
    Name = "LabNetPrv1${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_subnet" "LabNetPrv2" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.LabVpc.id
  cidr_block              = "10.0.${count.index + 1}2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, var.availability_zones[count.index % length(var.availability_zones)])

  tags = {
    Name = "LabNetPrv2${upper(var.availability_zones[count.index])}"
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

resource "aws_route_table" "LabRouteTablePrv1" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPub[count.index].id
  }

  tags = {
    Name = "LabRouteTablePrv1${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_route_table_association" "LabRouteTablePrv1" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.LabNetPrv1[count.index].id
  route_table_id = aws_route_table.LabRouteTablePrv1[count.index].id
}

resource "aws_route_table" "LabRouteTablePrv2" {
  count            = length(var.availability_zones)
  vpc_id           = aws_vpc.LabVpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.LabNatGwPub[count.index].id
  }

  tags = {
    Name = "LabRouteTablePrv2${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_route_table_association" "LabRouteTablePrv2" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.LabNetPrv2[count.index].id
  route_table_id = aws_route_table.LabRouteTablePrv2[count.index].id
}

resource "aws_network_acl" "LabAclPub" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.LabVpc.id
  subnet_ids = [aws_subnet.LabNetPub[count.index].id]

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "10.0.0.0/8"
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidr_block = "0.0.0.0/0"
  }
  
  ingress {
    rule_no    = 120
    action     = "allow"
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 130
    action     = "allow"
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 170
    action     = "allow"
    protocol   = "icmp"
    from_port  = 0
    to_port    = 0
    icmp_type  = -1
    icmp_code  = -1
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 180
    action     = "allow"
    protocol   = "tcp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no    = 190
    action     = "allow"
    protocol   = "udp"
    from_port  = 1024
    to_port    = 65535
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "LabAclPub${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_network_acl" "LabAclPrv1" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.LabVpc.id
  subnet_ids = [aws_subnet.LabNetPrv1[count.index].id]
  
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "LabAclPrv1${upper(var.availability_zones[count.index])}"
  }
}

resource "aws_network_acl" "LabAclPrv2" {
  count      = length(var.availability_zones)
  vpc_id     = aws_vpc.LabVpc.id
  subnet_ids = [aws_subnet.LabNetPrv2[count.index].id]
 
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
 
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "LabAclPrv2${upper(var.availability_zones[count.index])}"
  }
}

