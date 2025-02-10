variable "ami_id" {
  description = "ID da AMI para a instância EC2"
  type        = string
  default = "ami-012967cc5a8c9f891"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  default     = "t2.micro"
}
