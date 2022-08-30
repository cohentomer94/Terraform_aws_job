resource "aws_instance" "web" {
  ami = "ami-099a8245f5daa82bf"
  instance_type = "t2.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  associate_public_ip_address = true
      user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo service httpd start
              sudo echo "<html> <h1> HelloWorld </h1> </html>" > /var/www/html/index.html
             EOF
  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "webserver_sg" {
  name        = "application"
  description = "application network traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "80 from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/25","10.0.1.128/25"]
    security_groups  = [aws_security_group.alb.id]
  }

  ingress {
    description = "8080 from alb"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/25","10.0.1.128/25"]
    security_groups  = [aws_security_group.alb.id]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application allow traffic"
  }
}