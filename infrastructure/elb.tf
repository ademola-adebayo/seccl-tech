# NLB Security Group
resource "aws_security_group" "web-nlb-sg" {
  name                       = "loadbalalancer-sg"
  description                = "Allow all traffic from internet"
  vpc_id                     = aws_vpc.vpc.id
  
  
  egress {
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
  } 
  
}


resource "aws_security_group_rule" "ingress" { 
  for_each = var.ports

  security_group_id = aws_security_group.web-nlb-sg.id
  from_port = each.value
  to_port   = each.value
  protocol   = "tcp"
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_eip" "lb" {
  vpc = true
}

resource "aws_lb" "this" {
  name               = "${var.environment}-web-lb"
  internal           = false
  load_balancer_type = "network"
  /* subnets            = [aws_subnet.public_subnet.id] */

  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet.id
    allocation_id = aws_eip.lb.id
  }

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_listener" "this" {
  for_each = var.ports
  load_balancer_arn = aws_lb.this.arn
  port              = each.value
  protocol          = "TCP"
  /* certificate_arn   = aws_acm_certificate_validation.this.certificate_arn */
  /* alpn_policy       = "HTTP2Preferred" */

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }
}

resource "aws_lb_target_group" "this" {
  for_each = var.ports

  port     = each.value
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  depends_on = [aws_lb.this]
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.ports


  target_group_arn = aws_lb_target_group.this[each.key].arn
  target_id        = aws_instance.webserver.id
  port             = each.value /*visit this asap*/
}

