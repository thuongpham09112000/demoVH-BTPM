resource "aws_route53_zone" "R53Zone-Vpc01_local" {
  name          = "${lower(var.Vpc01)}.local."
  force_destroy = true

  vpc {
    vpc_id = aws_vpc.Vpc01_Vpc.id
  }
}

data "aws_route53_zone" "R53Zone-automata_guru" {
  name         = "automata.guru."
  private_zone = false
}
