resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public2.id]

  tags = {
    Name = "webserver_loadbalancer"
  }
}

resource "aws_lb_listener" "lb_l_http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "lb_l_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.httpscertificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wb_lb_tg.arn
  }
}

resource "aws_lb_target_group" "wb_lb_tg" {
  name     = "wblgtb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group_attachment" "lb_rt" {
  target_group_arn = aws_lb_target_group.wb_lb_tg.arn
  target_id        = aws_instance.myec2.id
  port             = 80
}