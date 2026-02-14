variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecs-bluegreen"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "container_name" {
  type    = string
  default = "app"
}

variable "github_org_repo" {
  type    = string
  default = "GXZIIFTI/secure-aws-platform"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "codedeploy_bucket" {
  description = "S3 bucket that stores CodeDeploy revision (appspec.yaml)"
  type        = string
}

