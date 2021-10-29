resource "aws_route53_zone" "this" {
  name = "boxlittle.com"
}

resource "aws_route53_record" "this" {
  name = "boxlittle.com"
  type = "A"

  records = [aws_eip.lb.public_ip]
  ttl = "300"
  zone_id = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate" "this" {
  domain_name       = "${var.dns_record_name}.${var.dns_zone_name}"
  validation_method = "DNS"

  tags = {
    Name = "Boxlittle Certificate"
  }
} 

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  
  /* validation_record_fqdns = [aws_route53_record.this.fqdn] */
  /* validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn] */

}


 resource "aws_route53_record" "cert_validation" { 
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl = 60
  zone_id = aws_route53_zone.this.zone_id
} 
