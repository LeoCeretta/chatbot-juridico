variable "region" {
  description = "AWS Region"
  default   = "us-east-1"
}

variable "profile" {
  description = "Meu perfil"
  default = "default"
}

variable "bucket_name" {
  description = "Nome do bucket S3"
  default = "chatbot-dataset-sprints7-8-compass"
}

variable "instance_name" {
  description = "Nome da instância EC2"
}

variable "key_name" {
  description = "Nome do par de chaves SSH para acessar a EC2"
}

variable "bedrock_model_name" {
  description = "Nome do modelo do Amazon Bedrock"
}

variable public_subnet_id {
  description = "ID of the public subnet"
}

variable security_group_id {
  description = "Grupo id of the security group"
}