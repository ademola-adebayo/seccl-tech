## Seccl Tech Test

Project: Creating an Hello World with Terraform or any configuration management tool
==================
# 

# Tasks:

1. Securely deploy an EC2 instance in a VPC, hosting a web server, behind a load balancer
2. The EC2 should have some form of logging and monitoring enabled
3. The web page the server returns should have TLS enabled and a domain name configured
4. Documentation in the form of a README.md 
5. Any additional config files you would usually add to the root of a git repository


## Solution
In achitecting this infrastructure, I put into consideration that we dont want our ec2 instance to be public facing.
so we have 2 subnets in a single availability zone. 
A public subnet houses our Network Load Balancer (NLB)
A private subnet that houses our EC2 instance.
our EC2 Instance is configure with Amazon Cloudwatch to monitor CPU Usage and to inform us when it goes above 80%.
Traffic flows into our EC2 Instance only from the NLB on port 80. 
Since our EC2 is in a private subnet with security group that only accepts ssh from a Bastion host(yet to be spinned up). It also has an elastic ip attached.

Monitoring and Logging
==================
Leverage the use of another aws managed solution in AWS Cloudtrail.
Cloudtrail logs and monitors our whole infrastructure and tracks incoming and outgoing traffic into our system.
It also logs all metrics and saves them in an S3 Bucket for versioning and to be viewed at a later date.