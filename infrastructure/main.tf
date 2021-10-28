provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh-key" {
  key_name   = "dove-key"
  public_key = file("${var.private_key_location}.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = "${var.environment}"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = {
    Name        = "${var.environment}-private-subnet"
    Environment = var.environment
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}


/* Routing table for public subnet */
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}


/* Route table associations */
resource "aws_route_table_association" "public-rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.latest-amazon-linux-image.id
  instance_type          = var.instancetype
  key_name               = aws_key_pair.ssh-key.key_name
  availability_zone      = "${var.region}a"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.private_subnet.id

  user_data = <<EOF
                         #!/bin/bash
                         sudo yum update -y
                         sudo yum install -y httpd
                         sudo service httpd start
                         sudo service httpd enable
                         "<h1 style='color: #BEC7C7;font-size: 20px'>Hello World via Terraform</h1>
                         " | sudo tee /var/www/html/index.html
                         echo "<h3 style='color: #ECED0C'>Thanks for having me</h3>" >> /var/www/html
                       EOF
  tags = {
    Name        = "${var.environment}-webserver"
    Environment = var.environment
  }

  /* provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/script.sh",
      "/tmp/script.sh"
    ]
  }

  connection {
    user        = var.USER
    private_key = file(var.private_key_location)
    host        = self.public_ip
  } */
}

/* Set up Cloudwatch on the webserver*/
resource "aws_cloudwatch_metric_alarm" "webserver" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions = {
    InstanceId = aws_instance.webserver.id
  }
}

resource "aws_security_group" "webserver-sg" {
  name        = "${var.environment}-web-server-sg"
  description = "Allow inbound traffic from NLB"
  vpc_id      = aws_vpc.vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.hostip}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-webserver-sg"
    Environment = var.environment
  }
}

/*ataching an eip to webserver instance*/
resource "aws_eip" "private-eip" {
  instance = aws_instance.webserver.id
  vpc      = true
}

