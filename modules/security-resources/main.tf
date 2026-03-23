data "aws_caller_identity" "current" {}

resource "aws_kms_key" "ebs_kms" {
  description             = "KMS key for EBS encryption"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "EnableRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        "Sid": "AllowAutoScalingUse",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:DescribeKey"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowASGGrant",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": "kms:CreateGrant",
        "Resource": "*",
        "Condition": {
            "Bool": {
            "kms:GrantIsForAWSResource": true
            }
        }
      }  
    ]
  })
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/ebs-key"
  target_key_id = aws_kms_key.ebs.key_id
}

resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 ALB logs"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "EnableRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Sid = "AllowS3UseOfKey",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "s3" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_s3_bucket" "s3_access_logs" {
  bucket = var.access_log_bucket_name
  depends_on = [ aws_kms_key.s3_kms ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
  depends_on = [ aws_kms_key.s3_kms ]
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
      }
    ]
  })
  depends_on = [ aws_s3_bucket.s3_access_logs ]
}

resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
#   ingress {
#     from_port = 80
#     to_port   = 80
#     protocol  = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  depends_on = [ aws_security_group.alb_sg ]
}

resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "example.com"
  validation_method = "DNS"
}