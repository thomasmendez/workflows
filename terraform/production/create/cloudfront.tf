locals {
  s3_origin_id = aws_s3_bucket.bucketprd.id
}
resource "aws_cloudfront_origin_access_identity" "bucketprd" {
  comment = "bucketprd"
}
data "aws_cloudfront_cache_policy" "cache_policy" {
  name = "Managed-CachingOptimized"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucketprd.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bucketprd.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"

  aliases = ["${var.sub_domain}.${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_policy.id
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.amazon_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}