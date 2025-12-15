terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"
  name   = var.project_name
  cidr   = var.vpc_cidr
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = var.bucket_name
}

module "security" {
  source     = "../../modules/security"
  name       = var.project_name
  bucket_arn = module.s3.bucket_arn
}

module "ec2" {
  source           = "../../modules/ec2"
  ami              = var.ami
  instance_type    = var.instance_type
  subnet_id        = module.vpc.public_subnet_id
  vpc_id           = module.vpc.vpc_id
  instance_profile = module.security.instance_profile
  bucket_name      = module.s3.bucket_name
}

module "apigw" {
  source  = "../../modules/api_gateway"
  name    = "${var.project_name}-api"
  ec2_url = "http://${module.ec2.public_ip}:5000/resize"
}

output "api_url" { value = module.apigw.invoke_url }
