resource "aws_instance" "Vpc01_Ec2-web" {
  count                  = length(var.availability_zones)
  ami                    = lookup(var.AMI_UBUNTU, var.AWS_REGION)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.Vpc01_NetPub[count.index % length(var.availability_zones)].id
  vpc_security_group_ids = [aws_security_group.Vpc01_SecGrpPub-web.id]
  user_data_base64       = base64gzip(templatefile("srv.ci", { hostname = "web${count.index + 1}" }))

  tags = {
    Name = "${var.Vpc01}Ec2-web${count.index + 1}"
  }
}

resource "aws_route53_record" "R53RecA-Vpc01_local-web" {
  count   = length(var.availability_zones)
  zone_id = aws_route53_zone.R53Zone-Vpc01_local.zone_id
  name    = "web${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Vpc01_Ec2-web[count.index].private_ip]
}

resource "aws_route53_record" "R53RecA-automata_guru-web" {
  count   = length(var.availability_zones)
  zone_id = data.aws_route53_zone.R53Zone-automata_guru.zone_id
  name    = "web${count.index + 1}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.Vpc01_Ec2-web[count.index].public_ip]
}

resource "aws_security_group" "Vpc01_SecGrpPub-web" {
  name        = "${var.Vpc01}SecGrpPub-web"
  vpc_id      = aws_vpc.Vpc01_Vpc.id

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
    Name = "${var.Vpc01}SecGrpPub-web"
  }
}
