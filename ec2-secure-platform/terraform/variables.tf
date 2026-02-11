variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "my_ip_cidr" {
  description = "My IP in CIDR notation for SSH (e.g. 1.2.3.4/32)"
  type        = string
  default     = "162.84.244.214/32" # change this to your IP for security
}

variable "app_port" {
  description = "Application port to open temporarily (using http port 8080)"
  type        = number
  default     = 8080
}