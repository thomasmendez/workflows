variable "env" {
  description = "Environment"
  type        = string
  default     = "prd"
}
variable "aws_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}
variable "domain" {
  description = "Domain Name"
  type        = string
}
variable "sub_domain" {
  description = "Sub Domain Name"
  type        = string
}