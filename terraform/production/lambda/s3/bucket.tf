resource "aws_s3_bucket" "bucket_prd" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucketprd" {
  bucket     = var.aws_bucket_name
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucketprd]
}

resource "aws_s3_bucket_ownership_controls" "bucketprd" {
  bucket = var.aws_bucket_name
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_prd" {
  bucket = aws_s3_bucket.bucket_prd.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
