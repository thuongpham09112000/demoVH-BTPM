resource "aws_instance" "Vpc01_Ec2-nms" {
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.Vpc01_NetPub[0].id
  vpc_security_group_ids = [aws_security_group.Vpc01_SecGrpPub-nms.id]
  private_ip             = "10.0.10.254"
  user_data_base64       = base64gzip(templatefile("nms.ci", { hostname = "nms" }))

  tags = {
    Name = "${var.Vpc01}Ec2-nms"
  }
}

resource "aws_route53_record" "R53RecA-Vpc01_local-nms" {
  zone_id = aws_route53_zone.R53Zone-Vpc01_local.zone_id
  name    = "nms"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Vpc01_Ec2-nms.private_ip]
}

resource "aws_route53_record" "R53RecA-automata_guru-nms" {
  zone_id = data.aws_route53_zone.R53Zone-automata_guru.zone_id
  name    = "nms"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Vpc01_Ec2-nms.public_ip]
}

resource "aws_security_group" "Vpc01_SecGrpPub-nms" {
  name        = "${var.Vpc01}SecGrpPub-nms"
  vpc_id      = aws_vpc.Vpc01_Vpc.id

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
    Name = "${var.Vpc01}SecGrpPub-nms"
  }
}
