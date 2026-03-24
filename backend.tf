terraform {
  backend "s3" {
    bucket         = "terraform-state-1212156"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    use_lockfile = true
    encrypt        = true
  }
}