resource "aws_api_gateway_rest_api" "api_gateway_dev" {
  name = "api_gateway_dev"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_method" "root_method_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_method_response_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method = aws_api_gateway_method.api_gateway_method_dev.http_method
  status_code = "200"

  response_models = {
       "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "root_method_integration_dev" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id             = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  http_method             = aws_api_gateway_method.api_gateway_method_dev.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_dev.invoke_arn
}

resource "aws_api_gateway_resource" "proxy_resource_dev" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.api_gateway_dev.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
}

resource "aws_api_gateway_method" "api_gateway_method_dev" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id   = aws_api_gateway_resource.proxy_resource_dev.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "api_gateway_method_response_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id = aws_api_gateway_resource.proxy_resource_dev.id
  http_method = aws_api_gateway_method.api_gateway_method_dev.http_method
  status_code = "200"

  response_models = {
       "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration_dev" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_dev.id
  resource_id             = aws_api_gateway_resource.proxy_resource_dev.id
  http_method             = aws_api_gateway_method.api_gateway_method_dev.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_dev.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway_dev.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_gateway_deployment_dev" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy_resource_dev.id,
      aws_api_gateway_method.root_method_dev.id,
      aws_api_gateway_integration.integration_dev.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "apigateway_stage_dev" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment_dev.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev.id
  stage_name    = "apigateway_stage_dev"
}
