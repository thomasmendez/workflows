output "iam_for_lambda_stg" {
  description = "Amazon Resource Name (ARN)"
  value       = aws_iam_role.iam_for_lambda_stg.arn
}