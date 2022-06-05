
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "allow http"
  vpc_id      = local.vpc_id

  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
   ingress {
    description      = "allow https"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      =  ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb_sg"
  }
}

#security group
resource "aws_security_group" "front_app_sg" {
  name        = "http"
  description = "allow http"
  vpc_id      = local.vpc_id

  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "front_app"
  }
}