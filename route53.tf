resource "aws_route53_zone" "R53_ZONE_LAB" {
  name          = "lab"
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.VPC_LAB.id
  }
}
