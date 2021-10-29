output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}
output "webserver_instance_ip" {
  description = "Public IP of the webserver instance"
  value = aws_instance.webserver.public_ip
}

output "name_server" {
  value = aws_route53_zone.this.name_servers
}