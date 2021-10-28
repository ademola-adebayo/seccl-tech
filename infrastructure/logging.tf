# log_group

resource "aws_cloudwatch_log_group" "sandbox-loggroup" {
	name = "training-loggroup"
}

# logstream

resource "aws_cloudwatch_log_stream" "logstream" {
  name           = "CloudWatchLogStream"
  log_group_name = aws_cloudwatch_log_group.sandbox-loggroup.name
}

# VPC Flow Logs
resource "aws_flow_log" "VPC_flow_log" {
  iam_role_arn   = aws_iam_role.flowlog_role.arn
  log_group_name = aws_cloudwatch_log_group.sandbox-loggroup.name
  
  vpc_id         = aws_vpc.vpc.id
  traffic_type   = "ALL"
}

resource "aws_iam_role" "flowlog_role" {
  name = "flowlog_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.flowlog_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Cloud Trail Logs for Mointoring

resource "aws_cloudtrail" "cloudtraillog" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = aws_s3_bucket.training.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
}

resource "aws_s3_bucket" "training" {
  bucket        = "${var.s3-bucket-name}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${var.s3-bucket-name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.s3-bucket-name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}