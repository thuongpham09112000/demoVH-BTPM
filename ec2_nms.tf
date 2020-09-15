resource "aws_instance" "LabEc2-labnms" {
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPub[0].id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPub-labnms.id]
  private_ip             = "10.0.10.254"
  user_data_base64       = base64gzip(templatefile("labnms.ci", { hostname = "labnms" }))

  tags = {
    Name = "LabEc2-labnms"
  }
}

resource "aws_route53_record" "LabLocalR53RecA-labnms" {
  zone_id = aws_route53_zone.LabLocalR53Zone.zone_id
  name    = "labnms"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labnms.private_ip]
}

resource "aws_route53_record" "AutomataGuruR53RecA-labnms" {
  zone_id = data.aws_route53_zone.AutomataGuruR53Zone.zone_id
  name    = "labnms"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labnms.public_ip]
}

resource "aws_security_group" "LabSecGrpPub-labnms" {
  name        = "LabSecGrpPub-labnms"
  vpc_id      = aws_vpc.LabVpc.id

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "LabSecGrpPub-labnms"
  }
}
