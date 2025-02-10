provider "aws" {
  region = var.region
  profile = var.profile
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.bucket_name
}

module "vpc" { 
  source = "./modules/vpc" 
}

module "ec2" {
  source            = "./modules/ec2"
  region = var.region
  s3_bucket = var.bucket_name
  key_pair_name = var.key_name
  public_subnet_id  = module.vpc.public_subnet_id
  security_group_id = module.vpc.security_group_id
}

module "api_gateway" {
  source       = "./modules/api-gateway"
  chatbot_public_dns = module.ec2.chatbot_public_dns
  
}

