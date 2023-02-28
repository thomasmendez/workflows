resource "aws_s3_bucket" "bucket_dev" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucket_dev" {
  bucket = var.aws_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "bucket_dev" {
  bucket = aws_s3_bucket.bucket_dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_dev" {
  bucket = aws_s3_bucket.bucket_dev.id
  rule {
    id = "cleanup"
    filter {} # applies to all objects in bucket
    status = "Enabled"
    expiration {
      days = 1
    }
  }
}

data "aws_s3_bucket" "bucket_dev" {
  bucket = var.aws_bucket_name
}

output "bucket_dev" {
  value = data.aws_s3_bucket.bucket_dev.bucket
}
