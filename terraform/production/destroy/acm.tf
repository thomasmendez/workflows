provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
# Find a certificate issued by (not imported into) ACM
data "aws_acm_certificate" "amazon_cert" {
  domain      = var.domain
  types       = ["AMAZON_ISSUED"]
  statuses    = ["ISSUED"]
  most_recent = true
  provider    = aws.virginia
}