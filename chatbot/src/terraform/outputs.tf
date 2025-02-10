
output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "api_gateway_url" {
  value = module.api_gateway.url
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}