terraform {
  backend "s3" {
    bucket         = "lavanya-bucket001"
    key            = "uc6/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}