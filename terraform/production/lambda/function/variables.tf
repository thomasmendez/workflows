variable "env" {
  description = "Environment"
  type        = string
  default     = "prd"
}
variable "aws_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "lambda_function_s3_key" {
  description = "Lambda S3 zip name for S3 bucket function"
  type        = string
  default     = "function.zip"
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_function_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "app.main.handler"
}

variable "lambda_function_runtime" {
  description = "Lambda function runtime and version"
  type        = string
  default     = "python3.9"
}
