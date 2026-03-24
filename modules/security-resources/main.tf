data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_role" {
  name = "application-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "application-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

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
  tags = {
      Name = "${var.resource_name}-ebs-key"
      Environment = var.environment
      CostCenter = var.cost_center
  }
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/ebs-key"
  target_key_id = aws_kms_key.ebs_kms.key_id
}

resource "aws_s3_bucket" "s3_access_logs" {
  bucket = var.access_log_bucket_name
  versioning {
    enabled = true
  }
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.s3_access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
}
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.s3_access_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.s3_access_logs.arn}/*"
      }
    ]
  })
}

resource "aws_security_group" "alb_sg" {
  name = "alb_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "${var.resource_name}-alb-sg"
      Environment = var.environment
      CostCenter = var.cost_center
  }
}

resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
      Name = "${var.resource_name}-ec2-sg"
      Environment = var.environment
      CostCenter = var.cost_center
  }
  depends_on = [ aws_security_group.alb_sg ]
}

resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "example.com"
  validation_method = "DNS"
}