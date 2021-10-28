output "webserver_instance_ip" {
  description = "Public IP of the webserver instance"
  value = aws_instance.webserver.public_ip
}

output "name_server" {
  value = aws_route53_zone.this.name_servers
}