resource "aws_instance" "LabEc2-labnms" {
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPubA.id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPub.id]
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

variable "ServerCount" {
  default = "3"
}

resource "aws_instance" "LabEc2-labsrv" {
  count                  = var.ServerCount
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPrvA.id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPrv.id]
  user_data_base64       = base64gzip(templatefile("labsrv.ci", { hostname = "labsrv${count.index + 1}" }))

  tags = {
    Name = "LabEc2-labsrv${count.index + 1}"
  }
}

resource "aws_route53_record" "LabLocalR53RecA-labsrv" {
  count   = var.ServerCount
  zone_id = aws_route53_zone.LabLocalR53Zone.zone_id
  name    = "labsrv${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labsrv[count.index].private_ip]
}

