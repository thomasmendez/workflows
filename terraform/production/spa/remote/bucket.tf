resource "aws_s3_bucket" "bucketprd" {
  bucket = var.aws_bucket_name
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketprd" {
  bucket = aws_s3_bucket.bucketprd.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucketprd" {
  bucket = aws_s3_bucket.bucketprd.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucketprd" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucketprd,
    aws_s3_bucket_public_access_block.bucketprd,
  ]

  bucket = aws_s3_bucket.bucketprd.id
  acl    = "public-read"
}

# resource "aws_s3_bucket_lifecycle_configuration" "bucketprd" {
#   bucket = aws_s3_bucket.bucketprd.id
#   rule {
#     id = "cleanup"
#     filter {} # applies to all objects in bucket
#     status = "Enabled"
#     expiration {
#       days = 1
#     }
#   }
# }

resource "aws_s3_bucket_policy" "bucketprd" {
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

resource "aws_s3_bucket_website_configuration" "bucketprd" {
  bucket = var.aws_bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

data "aws_s3_bucket" "bucketprd" {
  bucket = var.aws_bucket_name
}

output "bucketprd" {
  value = data.aws_s3_bucket.bucketprd.bucket
}
