terraform {
  backend "s3" {
    bucket         = "secure-platform-bucket123456"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
