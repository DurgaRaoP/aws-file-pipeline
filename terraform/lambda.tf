resource "aws_lambda_function" "file_processor" {
  filename         = "lambda_placeholder.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  source_code_hash = filebase64sha256("lambda_placeholder.zip")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.file_metadata.name
      SNS_TOPIC_ARN  = aws_sns_topic.file_upload_alerts.arn
    }
  }

  tags = {
    Name    = "FileProcessor"
    Project = var.project_name
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_pipeline_bucket.arn
}