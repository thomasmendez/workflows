resource "aws_s3_bucket" "bucketdev" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucketdev" {
  bucket = var.aws_bucket_name
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucketdev]
}

resource "aws_s3_bucket_ownership_controls" "bucketdev" {
  bucket =  var.aws_bucket_name
  rule {
    object_ownership = "ObjectWriter"
  }
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
