/*Security Group for Bastion Host*/
resource "aws_security_group" "bastion-sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.environment}-bastion-sg"
  description = "Allow SSH to bastion host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-bastion-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instancetype
  key_name                    = aws_key_pair.ssh-key.key_name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "bastion-eip" {
  instance = aws_instance.bastion.id
  vpc      = true
}
