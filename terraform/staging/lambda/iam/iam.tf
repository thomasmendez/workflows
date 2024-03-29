resource "aws_iam_role" "iam_for_lambda_stg" {
  name = "${var.lambda_function_name}-lambda-stg"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  tags = {
    Environment = var.env
  }
}