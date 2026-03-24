output "kms_ebs_key_id" {
  value = aws_kms_key.ebs_kms.arn
}

output "alb_sg" { 
    value = aws_security_group.alb_sg.id 
}

output "ec2_sg" { 
    value = aws_security_group.ec2_sg.id 
}

output "kms_key_id" { 
    value = aws_kms_key.ebs_kms.id 
    }
output "cert_arn" { 
    value = aws_acm_certificate.ssl_cert.arn 
}

output "log_bucket" { 
    value = aws_s3_bucket.s3_access_logs.bucket 
}
