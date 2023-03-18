output "iam_for_lambda_prd" {
  description = "Amazon Resource Name (ARN)"
  value       = aws_iam_role.iam_for_lambda_prd.arn
}