resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name    = "LambdaLogGroup"
    Project = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "${var.lambda_function_name}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Triggers when Lambda has 1 or more errors in 5 minutes"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.file_processor.function_name
  }

  alarm_actions = [aws_sns_topic.file_upload_alerts.arn]
  ok_actions    = [aws_sns_topic.file_upload_alerts.arn]

  tags = {
    Name    = "LambdaErrorAlarm"
    Project = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_alarm" {
  alarm_name          = "${var.lambda_function_name}-duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 20000
  alarm_description   = "Triggers when Lambda average duration exceeds 20 seconds"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.file_processor.function_name
  }

  alarm_actions = [aws_sns_topic.file_upload_alerts.arn]

  tags = {
    Name    = "LambdaDurationAlarm"
    Project = var.project_name
  }
}

resource "aws_cloudwatch_dashboard" "pipeline_dashboard" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Invocations"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Invocations",
            "FunctionName", var.lambda_function_name]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Errors"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Errors",
            "FunctionName", var.lambda_function_name]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Duration (ms)"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/Lambda", "Duration",
            "FunctionName", var.lambda_function_name]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "S3 Bucket Size"
          view   = "timeSeries"
          region = var.aws_region
          metrics = [
            ["AWS/S3", "BucketSizeBytes",
            "BucketName", var.bucket_name,
            "StorageType", "StandardStorage"]
          ]
          period = 86400
          stat   = "Average"
        }
      }
    ]
  })
}