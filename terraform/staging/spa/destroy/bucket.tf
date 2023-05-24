resource "aws_s3_bucket" "bucketstg" {
  bucket        = var.aws_bucket_name
  force_destroy = true
  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "bucket_stg" {
  bucket = var.aws_bucket_name
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.bucket_stg]
}

resource "aws_s3_bucket_ownership_controls" "bucket_stg" {
  bucket =  var.aws_bucket_name
  rule {
    object_ownership = "ObjectWriter"
  }
}

# resource "aws_s3_bucket_lifecycle_configuration" "bucketstg" {
#   bucket = aws_s3_bucket.bucketstg.id
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

resource "aws_s3_bucket_website_configuration" "bucketstg" {
  bucket = var.aws_bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

data "aws_s3_bucket" "bucketstg" {
  bucket = var.aws_bucket_name
}

output "bucketstg" {
  value = data.aws_s3_bucket.bucketstg.bucket
}
