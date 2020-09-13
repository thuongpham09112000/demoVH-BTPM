resource "aws_vpc" "VPC_LAB" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "VPC_LAB"
  }
}

resource "aws_vpc_dhcp_options" "DHCP_LAB" {
  domain_name         = "lab"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "DHCP_LAB"
  }
}

resource "aws_vpc_dhcp_options_association" "DHCP_LAB" {
  vpc_id          = aws_vpc.VPC_LAB.id
  dhcp_options_id = aws_vpc_dhcp_options.DHCP_LAB.id
}

resource "aws_security_group" "SG_LAB_PUB" {
  name        = "SG_LAB_PUB"
  description = "Allow inbound LAB traffic, SSH taffic from Internet  and all outbound traffic"
  vpc_id      = aws_vpc.VPC_LAB.id

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
    Name = "SG_LAB_PUB"
  }
}

resource "aws_security_group" "SG_LAB_PRV" {
  name        = "SG_LAB_PRV"
  description = "Allow only inbound LAB traffic and all outbound traffic"
  vpc_id      = aws_vpc.VPC_LAB.id

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
    Name = "SG_LAB_PRV"
  }
}

resource "aws_subnet" "NET_LAB_PUB-A" {
  vpc_id                  = aws_vpc.VPC_LAB.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.AWS_REGION, "a")

  tags = {
    Name = "NET_LAB_PUB-A"
  }
}

resource "aws_subnet" "NET_LAB_PRV-A" {
  vpc_id                  = aws_vpc.VPC_LAB.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.AWS_REGION, "a")

  tags = {
    Name = "NET_LAB_PRV-A"
  }
}

resource "aws_internet_gateway" "IG_LAB" {
  vpc_id = aws_vpc.VPC_LAB.id

  tags = {
    Name = "IG_LAB"
  }
}

resource "aws_eip" "EIP_LAB_PUB-A_NG" {
  vpc = true

  tags = {
    Name = "EIP_LAB_PUB-A_NG"
  }
}

resource "aws_nat_gateway" "NG_LAB_PUB-A" {
  allocation_id = aws_eip.EIP_LAB_PUB-A_NG.id
  subnet_id     = aws_subnet.NET_LAB_PUB-A.id

  tags = {
    Name = "NG_LAB_PUB-A"
  }
}

resource "aws_route_table" "RT_LAB_PUB-A" {
  vpc_id = aws_vpc.VPC_LAB.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG_LAB.id
  }

  tags = {
    Name = "RT_LAB_PUB-A"
  }
}

resource "aws_route_table_association" "RT_LAB_PUB-A" {
  subnet_id      = aws_subnet.NET_LAB_PUB-A.id
  route_table_id = aws_route_table.RT_LAB_PUB-A.id
}

resource "aws_route_table" "RT_LAB_PRV-A" {
  vpc_id           = aws_vpc.VPC_LAB.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NG_LAB_PUB-A.id
  }

  tags = {
    Name = "RT_LAB_PRV-A"
  }
}

resource "aws_route_table_association" "RT_LAB_PRV-A" {
  subnet_id      = aws_subnet.NET_LAB_PRV-A.id
  route_table_id = aws_route_table.RT_LAB_PRV-A.id
}

