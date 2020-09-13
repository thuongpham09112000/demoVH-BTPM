resource "aws_instance" "EC2_LABNMS" {
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.NET_LAB_PUB-A.id
  vpc_security_group_ids = [aws_security_group.SG_LAB_PUB.id]
  private_ip             = "10.0.10.254"
  user_data_base64       = base64gzip(templatefile("labnms.ci", { hostname = "labnms" }))

  tags = {
    Name = "EC2_LABNMS"
  }
}

resource "aws_route53_record" "R53_A_LABNMS" {
  zone_id = aws_route53_zone.R53_ZONE_LAB.zone_id
  name    = "labnms"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.EC2_LABNMS.private_ip]
}

variable "LABSRV_COUNT" {
  default = "3"
}

resource "aws_instance" "EC2_LABSRV" {
  count                  = var.LABSRV_COUNT
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.NET_LAB_PRV-A.id
  vpc_security_group_ids = [aws_security_group.SG_LAB_PRV.id]
  user_data_base64       = base64gzip(templatefile("labsrv.ci", { hostname = "labsrv${count.index + 1}" }))

  tags = {
    Name = "EC2_LABSRV${count.index + 1}"
  }
}

resource "aws_route53_record" "R53_A_LABSRV" {
  count   = var.LABSRV_COUNT
  zone_id = aws_route53_zone.R53_ZONE_LAB.zone_id
  name    = "labsrv${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.EC2_LABSRV[count.index].private_ip]
}

