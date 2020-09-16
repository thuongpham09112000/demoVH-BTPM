resource "aws_eip" "LabEipNlb" {
  tags    = {
    Name  = "LabEipNlb"
  }
}

resource "aws_lb" "LabNlb" {
  name               = "LabNlb"
  load_balancer_type = "network"
  subnets            = [for i in range(length(var.availability_zones)) : aws_subnet.LabNetPub[i].id]

  tags = {
    Name = "LabNlb"
  }
}

resource "aws_lb_listener" "LabNlbListenerWeb" {
  load_balancer_arn = aws_lb.LabNlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.LabNlbTgGrpWeb.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "LabNlbTgGrpWeb" {
  name                  = "LabNlbTgGrpWeb"
  port                  = 80
  protocol              = "TCP"
  vpc_id                  = aws_vpc.LabVpc.id
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
    Name = "LabNlbTgGrpWeb"
  }
}

resource "aws_lb_target_group_attachment" "LabNlbTgGrpAttchWeb" {
  count             = length(var.availability_zones)
  target_group_arn  = aws_lb_target_group.LabNlbTgGrpWeb.arn
  port              = 80
  target_id         = aws_instance.LabEc2-labweb[count.index].id
}

# Optional Route53 configuration using CNAME instead of alias
#
# resource "aws_route53_record" "AutomataGuruR53RecA-web" {
#   zone_id = data.aws_route53_zone.AutomataGuruR53Zone.zone_id
#   name    = "web"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_lb.LabNlb.dns_name]
# }

resource "aws_route53_record" "AutomataGuruR53RecA-web" {
  zone_id = data.aws_route53_zone.AutomataGuruR53Zone.zone_id
  name    = "web"
  type    = "A"

  alias {
    name                   = aws_lb.LabNlb.dns_name
    zone_id                = aws_lb.LabNlb.zone_id
    evaluate_target_health = true
  }
}




