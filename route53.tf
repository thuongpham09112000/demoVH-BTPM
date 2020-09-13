resource "aws_route53_zone" "LabR53Zone" {
  name          = "lab"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.LabVpc.id
  }
}
