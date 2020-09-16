resource "aws_instance" "LabEc2-labapp" {
  count                  = length(var.availability_zones)
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPrv1[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPrv1-labapp.id]
  user_data_base64       = base64gzip(templatefile("labsrv.ci", { hostname = "labapp${count.index + 1}" }))

  tags = {
    Name = "LabEc2-labapp${count.index + 1}"
  }
}

resource "aws_route53_record" "LabLocalR53RecA-labapp" {
  count   = length(var.availability_zones)
  zone_id = aws_route53_zone.LabLocalR53Zone.zone_id
  name    = "labapp${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labapp[count.index].private_ip]
}

resource "aws_security_group" "LabSecGrpPrv1-labapp" {
  name        = "LabSecGrpPrv1-labapp"
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
    Name = "LabSecGrpPrv1-labapp"
  }
}
