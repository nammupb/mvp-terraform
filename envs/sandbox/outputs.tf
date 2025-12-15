output "ec2_public_ip" { value = module.ec2.public_ip }
output "api_url"        { value = module.apigw.invoke_url }
output "s3_bucket"      { value = module.s3.bucket_name }
