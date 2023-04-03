resource "aws_api_gateway_rest_api" "api_gateway_stg" {
  name = "${var.lambda_function_name}-api-gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root_method_stg" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id   = aws_api_gateway_rest_api.api_gateway_stg.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_method_response_stg" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id = aws_api_gateway_rest_api.api_gateway_stg.root_resource_id
  http_method = aws_api_gateway_method.api_gateway_method_stg.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "root_method_integration_stg" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id             = aws_api_gateway_rest_api.api_gateway_stg.root_resource_id
  http_method             = aws_api_gateway_method.api_gateway_method_stg.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_stg.invoke_arn
}

resource "aws_api_gateway_resource" "proxy_resource_stg" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.api_gateway_stg.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway_stg.id
}

resource "aws_api_gateway_method" "api_gateway_method_stg" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id   = aws_api_gateway_resource.proxy_resource_stg.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_method_response_stg" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id = aws_api_gateway_resource.proxy_resource_stg.id
  http_method = aws_api_gateway_method.api_gateway_method_stg.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration_stg" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_stg.id
  resource_id             = aws_api_gateway_resource.proxy_resource_stg.id
  http_method             = aws_api_gateway_method.api_gateway_method_stg.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_stg.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_stg.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway_stg.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment_stg" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_stg.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy_resource_stg.id,
      aws_api_gateway_method.root_method_stg.id,
      aws_api_gateway_integration.integration_stg.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_gateway_stage_stg" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment_stg.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_stg.id
  stage_name    = var.env
}
