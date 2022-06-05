
locals {
  vpc_id = data.aws_vpc.vpc.id
  pub_subnet = [for i in data.aws_subnet.public_sub: i.id]
  pri_subnet = [for i in data.aws_subnet.priv_sub: i.id]
}

data "aws_ami" "ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_key_pair" "kojitechs_keypair" {
  key_name = "kojitech_keypair"
}

# we'll use data source to pull priv_subnet_id, pub_subnet

data "aws_vpc" "vpc" {
    filter {
      name = "tag:Name"
      values = ["kojitechs_vpc"]
    }
}

# Pulling down priv_subnet 
data "aws_subnet_ids" "priv_subnet" {
  vpc_id = local.vpc_id
    filter {
      name = "tag:Name"
      values = ["priv_*"]
    }
}

data "aws_subnet_ids" "pub_subnet" {
  vpc_id = local.vpc_id
     filter {
      name = "tag:Name"
      values = ["pub_*"]
    }
}

# priv_subnet
data "aws_subnet" "priv_sub" {
  for_each = data.aws_subnet_ids.priv_subnet.ids 
  id = each.value
}

# public_subfornet
data "aws_subnet" "public_sub" {
    for_each = data.aws_subnet_ids.pub_subnet.ids
    id = each.value
}


# apache (index.html) # . app1, app2
resource "aws_instance" "front_endapp1" {
  ami           = data.aws_ami.ami.id
  instance_type = "t2.micro"
  subnet_id     = local.pri_subnet[0]
  key_name = data.aws_key_pair.kojitechs_keypair.key_name
  vpc_security_group_ids = [aws_security_group.front_app_sg.id]
  user_data =  file("${path.module}/template/frontend_app1.sh") 

  tags = {
    Name = "front_endapp1"
  }
}

resource "aws_instance" "front_endapp2" {
  ami           = data.aws_ami.ami.id
  instance_type = "t2.micro"
  subnet_id     = local.pri_subnet[1]
  key_name = data.aws_key_pair.kojitechs_keypair.key_name
  vpc_security_group_ids = [aws_security_group.front_app_sg.id]
  user_data =  file("${path.module}/template/frontend_app2.sh")

  tags = {
    Name = "front_endapp2"
  }
}

