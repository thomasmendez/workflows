resource "aws_s3_bucket" "bucketstg" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketstg" {
  bucket = aws_s3_bucket.bucketstg.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucketstg" {
  bucket = aws_s3_bucket.bucketstg.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucketstg" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucketstg,
    aws_s3_bucket_public_access_block.bucketstg,
  ]

  bucket = aws_s3_bucket.bucketstg.id
  acl    = "public-read"
}

# resource "aws_s3_bucket_lifecycle_configuration" "bucketstg" {
#   bucket = var.aws_bucket_name
#   rule {
#     id = "cleanup"
#     filter {} # applies to all objects in bucket
#     status = "Enabled"
#     expiration {
#       days = 1
#     }
#   }
# }

resource "aws_s3_bucket_policy" "bucketstg" {
  bucket = aws_s3_bucket.bucketstg.id
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

resource "aws_s3_bucket_website_configuration" "bucketstg" {
  bucket = var.aws_bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}