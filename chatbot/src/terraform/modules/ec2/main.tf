module "aws_launch_template" {
  source = "./template_ec2"
}

module "public_subnet_id" {
  source = "../vpc"
}

resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "my_key_pair" {
  content  = tls_private_key.my_key_pair.private_key_pem
  filename = "chatbot_key.pem"
}

resource "aws_key_pair" "chatbot_key" {
  key_name   = "chatbot_key"
  public_key = tls_private_key.my_key_pair.public_key_openssh
}


resource "aws_instance" "chatbot" {

  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.chatbot_key.key_name
  subnet_id                   = var.public_subnet_id
  security_groups             = [var.security_group_id]


  launch_template {
    id      = module.aws_launch_template.launch_template_id
    version = "$Latest"
  }

  provisioner "file" {
    source      = "../services"
    destination = "/home/ec2-user/services"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key =local_file.my_key_pair.content
  }

  user_data = file("server-script.sh")
}
