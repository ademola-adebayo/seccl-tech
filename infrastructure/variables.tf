variable "region" {}

variable "bastion_ami" {
  type = map(any)
  default = {
    us-east-1 = "ami-0e341fcaad89c3650"
    us-east-2 = "ami-00d1ab6b335f217cf"
    eu-west-1 = "ami-0dea0cf236484a796"
  }
}

variable "ports" {
  type = map(number)
  default = {
    TCP  = 80
    TLS  = 443
  }
}

variable "forwarding_config" {
  default = {
    80  = "TCP"
    443 = "TCP"
  }
}

variable "availability_zone" {
  description = "The region to launch the bastion host"
  default     = "us-east-1a"
}

variable "environment" {
  description = "Application Name"
  default     = "Dev"
}

variable "key_name" {
  description = "The aws keypair to use"
}

variable "appname" {
  description = "Application Name"
  default     = "Web"
}

variable "instancetype" {
  description = "Instance Type used for Instance "
  default     = "t2.micro"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "vpc_cidr" {
  description = "cidr block for vpc"
  type        = string
}
variable "s3-bucket-name" {
  description = "Bucket Name"
  default = "boxlittle-cloudtrail.123"
}

variable "trail_name" {
  description = "Default Cloud Trail for the VPC"
  default = "boxlittle-cloud-trail"
}

variable "hostip" {
  description = " Host IP to be allowed SSH for"
}

variable "pvtip" {
  description = "Host IP to be allowed SSH for"
}

variable "pvt-IP" {
  description = " Host IP to be allowed SSH for"
}

variable "private_key_location" {}


variable "dns_zone_name" {
  default = "com"
}

variable "dns_record_name" {
  default = "boxlittle"
}