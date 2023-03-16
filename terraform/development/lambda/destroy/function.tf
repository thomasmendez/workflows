resource "aws_lambda_function" "lambda_dev" {
  s3_bucket     = var.aws_bucket_name
  s3_key        = var.lambda_function_s3_key
  function_name = var.lambda_function_name
  role          = data.aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_function_handler
  runtime       = var.lambda_function_runtime
}

data "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
}
