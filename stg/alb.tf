#--------------------------------------------------------------
# ALB
#--------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.securityGroup.ids[var.sg_names["alb"]]
  ]
  subnets = [
    module.subnet.ids[var.subnet_names["pub1"]],
    module.subnet.ids[var.subnet_names["pub2"]]
  ]
}
 
#--------------------------------------------------------------
# ALB Target Group
#--------------------------------------------------------------
resource "aws_lb_target_group" "main" {
  name                 = "my-alb-tg"
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = module.vpc.id
  deregistration_delay = "60"
 
  health_check {
    interval            = "10"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "4"
    healthy_threshold   = "2"
    unhealthy_threshold = "10"
    matcher             = "200-302"
  }
}
 
#--------------------------------------------------------------
# ALB listner
#--------------------------------------------------------------
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}