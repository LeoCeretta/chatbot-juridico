resource "aws_launch_template" "ec2-instance-terraform-template-module" {
  
  instance_type = var.instance_type
  image_id = var.ami_id  

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "instance-chatbot-telegram"
      CostCenter = ""
      Project = ""
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "instance-chatbot-telegram"
      CostCenter = ""
      Project = ""
    }
  }
}

# Output do ID do Launch Template
output "launch_template_id" {
  value       = aws_launch_template.ec2-instance-terraform-template-module.id
  description = "The ID of the AWS Launch Template"
}