resource "aws_vpc" "chatbotvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "ChatbotVPC"
  }
}

resource "aws_security_group" "sshtraffic" {
  name   = "sshtraffic"
  vpc_id = aws_vpc.chatbotvpc.id

  tags = {
    Name = "ssh_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sshtraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.sshtraffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.chatbotvpc.id
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.chatbotvpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_internet_gateway" "chatbot_gateway" {
  vpc_id = aws_vpc.chatbotvpc.id

  tags = {
    Name = "Chatbot VPC IG"
  }
}

resource "aws_route_table" "second_rt" {
  vpc_id = aws_vpc.chatbotvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chatbot_gateway.id
  }

  tags = {
    Name = "My Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  route_table_id = aws_route_table.second_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}
