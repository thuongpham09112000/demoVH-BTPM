resource "aws_eip" "Vpc01_EipNlb" {
  tags    = {
    Name  = "Vpc01_EipNlb"
  }
}

resource "aws_lb" "Vpc01_Nlb" {
  name               = "${var.Vpc01}Nlb"
  load_balancer_type = "network"
  subnets            = [for i in range(length(var.availability_zones)) : aws_subnet.Vpc01_NetPub[i].id]

  tags = {
    Name = "${var.Vpc01}Nlb"
  }
}

resource "aws_lb_listener" "Vpc01_NlbListenerWeb" {
  load_balancer_arn = aws_lb.Vpc01_Nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.Vpc01_NlbTgGrpWeb.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "Vpc01_NlbTgGrpWeb" {
  name                  = "${var.Vpc01}NlbTgGrpWeb"
  port                  = 80
  protocol              = "TCP"
  vpc_id                  = aws_vpc.Vpc01_Vpc.id
  target_type             = "instance"
  deregistration_delay    = 90

  health_check {
    interval            = 10
    port                = 80
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "${var.Vpc01}NlbTgGrpWeb"
  }
}

resource "aws_lb_target_group_attachment" "Vpc01_NlbTgGrpAttchWeb" {
  count             = length(var.availability_zones)
  target_group_arn  = aws_lb_target_group.Vpc01_NlbTgGrpWeb.arn
  port              = 80
  target_id         = aws_instance.Vpc01_Ec2-web[count.index].id
}

# Optional Route53 configuration using CNAME instead of alias, cant be Apex though
#
# resource "aws_route53_record" "GuruR53RecA-automata_guru-www" {
#   zone_id = data.aws_route53_zone.R53Zone-automata_guru.zone_id
#   name    = "www"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_lb.Vpc01_Nlb.dns_name]
# }

resource "aws_route53_record" "R53RecA-automata_guru-Apex" {
  zone_id = data.aws_route53_zone.R53Zone-automata_guru.zone_id
  name    = "automata.guru."
  type    = "A"

  alias {
    name                   = aws_lb.Vpc01_Nlb.dns_name
    zone_id                = aws_lb.Vpc01_Nlb.zone_id
    evaluate_target_health = true
  }
}
