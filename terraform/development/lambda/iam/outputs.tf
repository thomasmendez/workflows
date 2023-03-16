output "iam_for_lambda_dev" {
  description = "Amazon Resource Name (ARN)"
  value = aws_iam_role.iam_for_lambda_dev.arn
}