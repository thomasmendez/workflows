resource "aws_s3_bucket" "bucket_dev" {
  bucket        = var.aws_bucket_name
  force_destroy = true
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucketdev" {
  bucket     = var.aws_bucket_name
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucketdev]
}

resource "aws_s3_bucket_ownership_controls" "bucketdev" {
  bucket = var.aws_bucket_name
  rule {
    object_ownership = "ObjectWriter"
  }
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
