resource "aws_instance" "LabEc2-labprv" {
  count                  = length(var.availability_zones)
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.LabNetPrv[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.LabSecGrpPrv.id]
  user_data_base64       = base64gzip(templatefile("labsrv.ci", { hostname = "labprv${count.index + 1}" }))

  tags = {
    Name = "LabEc2-labprv${count.index + 1}"
  }
}

resource "aws_route53_record" "LabLocalR53RecA-labprv" {
  count   = length(var.availability_zones)
  zone_id = aws_route53_zone.LabLocalR53Zone.zone_id
  name    = "labprv${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.LabEc2-labprv[count.index].private_ip]
}

