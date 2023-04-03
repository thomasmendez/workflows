# resource "aws_api_gateway_rest_api" "api_gateway_prd" {
#   name = "${var.lambda_function_name}-api-gateway"

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_method" "root_method_prd" {
#   rest_api_id   = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id   = aws_api_gateway_rest_api.api_gateway_prd.root_resource_id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "root_method_response_prd" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id = aws_api_gateway_rest_api.api_gateway_prd.root_resource_id
#   http_method = aws_api_gateway_method.api_gateway_method_prd.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }
# }

# resource "aws_api_gateway_integration" "root_method_integration_prd" {
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id             = aws_api_gateway_rest_api.api_gateway_prd.root_resource_id
#   http_method             = aws_api_gateway_method.api_gateway_method_prd.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.lambda_prd.invoke_arn
# }

# resource "aws_api_gateway_resource" "proxy_resource_prd" {
#   path_part   = "{proxy+}"
#   parent_id   = aws_api_gateway_rest_api.api_gateway_prd.root_resource_id
#   rest_api_id = aws_api_gateway_rest_api.api_gateway_prd.id
# }

# resource "aws_api_gateway_method" "api_gateway_method_prd" {
#   rest_api_id   = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id   = aws_api_gateway_resource.proxy_resource_prd.id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method_response" "api_gateway_method_response_prd" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id = aws_api_gateway_resource.proxy_resource_prd.id
#   http_method = aws_api_gateway_method.api_gateway_method_prd.http_method
#   status_code = "200"

#   response_models = {
#     "application/json" = "Empty"
#   }
# }

# resource "aws_api_gateway_integration" "integration_prd" {
#   rest_api_id             = aws_api_gateway_rest_api.api_gateway_prd.id
#   resource_id             = aws_api_gateway_resource.proxy_resource_prd.id
#   http_method             = aws_api_gateway_method.api_gateway_method_prd.http_method
#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.lambda_prd.invoke_arn
# }

# resource "aws_lambda_permission" "api_gateway_lambda" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda_prd.function_name
#   principal     = "apigateway.amazonaws.com"

#   source_arn = "${aws_api_gateway_rest_api.api_gateway_prd.execution_arn}/*/*"
# }

# resource "aws_api_gateway_deployment" "api_gateway_deployment_prd" {
#   rest_api_id = aws_api_gateway_rest_api.api_gateway_prd.id

#   triggers = {
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.proxy_resource_prd.id,
#       aws_api_gateway_method.root_method_prd.id,
#       aws_api_gateway_integration.integration_prd.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "api_gateway_stage_prd" {
#   deployment_id = aws_api_gateway_deployment.api_gateway_deployment_prd.id
#   rest_api_id   = aws_api_gateway_rest_api.api_gateway_prd.id
#   stage_name    = var.env
# }
