resource "aws_route53_zone" "LabLocalR53Zone" {
  name          = "lab.local."
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.LabVpc.id
  }
}

data "aws_route53_zone" "AutomataGuruR53Zone" {
  name         = "automata.guru."
  private_zone = false
}
