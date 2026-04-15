variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "aws-file-pipeline"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "S3 bucket name for file uploads"
  type        = string
  default     = "file-pipeline-arceus-2025"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "file-processor"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for file metadata"
  type        = string
  default     = "file-pipeline-metadata"
}

variable "sns_topic_name" {
  description = "SNS topic name for file upload alerts"
  type        = string
  default     = "file-upload-alerts"
}

variable "alert_email" {
  description = "Email address for pipeline alerts"
  type        = string
  default     = "aws.profile.durgarao@gmail.com"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}