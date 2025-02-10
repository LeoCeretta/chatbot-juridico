variable "region" {
  description = "Região AWS"
  type        = string
}

variable "s3_bucket" {
  description = "Bucket S3 onde o código do chatbot está armazenado"
  type        = string
}

variable "key_pair_name" {
  description = "Nome do par de chaves para acessar a instância"
  type        = string
}

variable "private_key_path" {
  description = "Caminho para a chave privada SSH"
  type        = string
  default     = "./"
}


variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}
