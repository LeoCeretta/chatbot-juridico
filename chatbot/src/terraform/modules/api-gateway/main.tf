resource "aws_api_gateway_rest_api" "telegram_api" {
  name = "telegram_api"
}

resource "aws_api_gateway_resource" "telegram_resource" {
  rest_api_id = aws_api_gateway_rest_api.telegram_api.id
  parent_id   = aws_api_gateway_rest_api.telegram_api.root_resource_id
  path_part   = "chatbot"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.telegram_api.id
  resource_id   = aws_api_gateway_resource.telegram_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "telegram_integration" {
  rest_api_id = aws_api_gateway_rest_api.telegram_api.id
  resource_id = aws_api_gateway_resource.telegram_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  type        = "HTTP"
  uri         = "http://${var.chatbot_public_dns}/webhook"
  integration_http_method = "POST"
}

