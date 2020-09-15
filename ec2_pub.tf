resource "aws_instance" "LabEc2-labpub" {
  count                  = length(var.availability_zones)
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPub[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPub-labpub.id]
  user_data_base64       = base64gzip(templatefile("labsrv.ci", { hostname = "labpub${count.index + 1}" }))

  tags = {
    Name = "LabEc2-labpub${count.index + 1}"
  }
}

resource "aws_route53_record" "LabLocalR53RecA-labpub" {
  count   = length(var.availability_zones)
  zone_id = aws_route53_zone.LabLocalR53Zone.zone_id
  name    = "labpub${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labpub[count.index].private_ip]
}

resource "aws_route53_record" "AutomataGuruR53RecA-labpub" {
  count   = length(var.availability_zones)
  zone_id = data.aws_route53_zone.AutomataGuruR53Zone.zone_id
  name    = "labpub${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labpub[count.index].public_ip]
}

resource "aws_security_group" "LabSecGrpPub-labpub" {
  name        = "LabSecGrpPub-labpub"
  vpc_id      = aws_vpc.LabVpc.id

  ingress {
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "LabSecGrpPub-labpub"
  }
}
