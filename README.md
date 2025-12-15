
# Image Resizer MVP – Terraform + EC2 + API Gateway

This is a conceptual MVP infrastructure project. 
It uses Terraform to *define* AWS resources but is **never deployed** (sandbox only).

## What it does

- Client sends an image via API.
- API forwards the request to an EC2-hosted service.
- EC2 server resizes the image (using ImageMagick, Pillow, Sharp, etc.).
- EC2 uploads the resized image to S3.
- Returns the resized image URL.

## AWS Services Used

## Features
- EC2 instance running a Flask + Pillow image-resizing microservice  
- S3 bucket for storing original + resized images  
- API Gateway forwarding requests to EC2  
- IAM Role for EC2 to access S3  
- VPC with public subnet + IGW  
- Clean Terraform module structure  
- No external dependencies, AWS-free sandbox

## Project Structure
```
mvp-terraform/
├── modules/
│   ├── vpc/
│   ├── s3/
│   ├── ec2/
│   ├── security/
│   └── api_gateway/
└── envs/
    └── sandbox/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```
## Architecture Diagram


## How the System Works
1. API Gateway receives POST /resize with an uploaded image.
2. API Gateway forwards the request to EC2 instance (port 5000).
3. EC2 instance runs Flask + Pillow + Gunicorn, resizes image.
4. EC2 uploads original and resized images to S3.
5. IAM Role grants EC2 access to S3.

## Terraform Modules Overview
- **VPC Module**: VPC, public subnet, IGW, route table.
- **S3 Module**: Versioned + encrypted bucket.
- **Security Module**: IAM Role + instance profile for EC2.
- **EC2 Module**: EC2 instance, security group, user-data bootstrap.
- **API Gateway Module**: REST API, POST /resize endpoint, HTTP proxy to EC2.

## How to Work Locally (No Deployment)
```
cd mvp-terraform/envs/sandbox
terraform init
terraform validate
terraform plan -refresh=false
```
> Using -refresh=false avoids AWS calls.

## Local Testing (Optional)
```
pip install flask pillow boto3
python app.py
curl -X POST -F "file=@image.jpg" http://localhost:5000/resize
```
