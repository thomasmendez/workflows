output "base_url" {
  description = "Base URL for API Gateway stage"

  value = aws_api_gateway_stage.apigateway_stage_dev.invoke_url
}
