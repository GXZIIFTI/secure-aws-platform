terraform {
  backend "s3" {
    bucket         = "tfstate-ecs-cicd-bluegreen77"
    key            = "ecs-cicd-bluegreen/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tflock-ecs-cicd-bluegreen"
    encrypt        = true
  }
}
