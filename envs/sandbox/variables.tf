variable "project_name" {
  type    = string
  default = "image-resizer-ec2-mvp"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bucket_name" {
  type    = string
  default = "image-resizer-ec2-sandbox-unique-12345"
}

variable "ami" {
  type    = string
  default = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
