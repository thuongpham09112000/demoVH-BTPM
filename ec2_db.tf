resource "aws_instance" "Vpc01_Ec2-db" {
  count                  = length(var.availability_zones)
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.Vpc01_NetPrv2[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.Vpc01_SecGrpPrv2-db.id]
  user_data_base64       = base64gzip(templatefile("srv.ci", { hostname = "db${count.index + 1}" }))

  tags = {
    Name = "${var.Vpc01}Ec2-db${count.index + 1}"
  }
}

resource "aws_route53_record" "R53RecA-Vpc01_local-db" {
  count   = length(var.availability_zones)
  zone_id = aws_route53_zone.R53Zone-Vpc01_local.zone_id
  name    = "db${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Vpc01_Ec2-db[count.index].private_ip]
}

resource "aws_security_group" "Vpc01_SecGrpPrv2-db" {
  name        = "Vpc01_SecGrpPrv2-db"
  vpc_id      = aws_vpc.Vpc01_Vpc.id

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
    Name = "${var.Vpc01}SecGrpPrv2-db"
  }
}
