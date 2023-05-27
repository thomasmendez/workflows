resource "aws_s3_bucket" "bucketdev" {
  bucket        = var.aws_bucket_name
  force_destroy = true
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketdev" {
  bucket = aws_s3_bucket.bucketdev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucketdev" {
  bucket = aws_s3_bucket.bucketdev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucketdev" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucketdev,
    aws_s3_bucket_public_access_block.bucketdev,
  ]

  bucket = aws_s3_bucket.bucketdev.id
  acl    = "public-read"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucketdev" {
  bucket = aws_s3_bucket.bucketdev.id
  rule {
    id = "cleanup"
    filter {} # applies to all objects in bucket
    status = "Enabled"
    expiration {
      days = 1
    }
  }
}

resource "aws_s3_bucket_policy" "bucketdev" {
  bucket = var.aws_bucket_name
  policy = <<EOF
{
  "Id": "MakePublic",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.aws_bucket_name}/*",
      "Principal": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_website_configuration" "bucketdev" {
  bucket = var.aws_bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

data "aws_s3_bucket" "bucketdev" {
  bucket = var.aws_bucket_name
}

output "bucketdev" {
  value = data.aws_s3_bucket.bucketdev.bucket
}
