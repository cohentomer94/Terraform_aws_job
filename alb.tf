resource "aws_lb_target_group" "my_api" {
  name     = "tf-wordpress-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id      = aws_vpc.prod_vpc.id
}

resource "aws_alb" "my_api" {
  name               = "my-api-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  security_groups = [
    aws_security_group.alb.id
  ]
}
resource "aws_alb_listener" "my_api_http" {
  load_balancer_arn = aws_alb.my_api.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_api.arn
  }
}


resource "aws_security_group" "alb" {
  name        = "alb"
  description = "alb network traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow traffic"
  }
}

  resource "aws_lb_target_group_attachment" "wordpressa_tg_attachment" {
  target_group_arn = aws_lb_target_group.my_api.arn
  target_id        = aws_instance.web.id
  port             = 80
} 
 

 
