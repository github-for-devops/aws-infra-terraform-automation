terraform {
  backend "s3" {
    bucket         = "terra-state-bucket-1212121215"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    use_lockfile = true
    encrypt        = true
  }
}