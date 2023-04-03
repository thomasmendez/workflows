output "base_url" {
  description = "Base URL for API Gateway stage"

  value = aws_api_gateway_stage.api_gateway_stage_stg.invoke_url
}
