resource "aws_s3_bucket" "bucket_stg" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucket_stg" {
  bucket = var.aws_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket_stg" {
  bucket = aws_s3_bucket.bucket_stg.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
