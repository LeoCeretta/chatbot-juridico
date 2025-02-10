output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.chatbot.id
}

output "chatbot_public_dns" {
  value       = aws_instance.chatbot.public_dns
  description = "Public DNS of the EC2 instance hosting the chatbot"
}