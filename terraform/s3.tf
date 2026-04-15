resource "aws_s3_bucket" "file_pipeline_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = "FilePipelineBucket"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_versioning" "file_pipeline_versioning" {
  bucket = aws_s3_bucket.file_pipeline_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "file_upload_notification" {
  bucket = aws_s3_bucket.file_pipeline_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}