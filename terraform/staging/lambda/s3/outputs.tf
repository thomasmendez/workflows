output "bucket_stg" {
  description = "Amazon Resource Name (ARN)"
  value       = aws_s3_bucket.bucket_stg.arn
}