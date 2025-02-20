output "vpc_id" {
  value = aws_vpc.chatbotvpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.sshtraffic.id
}
