resource "aws_s3_bucket" "chatbot" {
  bucket = var.bucket_name
}

resource "null_resource" "dataset_upload" {
  provisioner "local-exec" {
    command = "aws s3 sync ../../../dataset/ s3://${aws_s3_bucket.chatbot.id}/dataset/"
  }
  depends_on = [aws_s3_bucket.chatbot]
}