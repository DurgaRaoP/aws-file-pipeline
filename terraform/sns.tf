resource "aws_sns_topic" "file_upload_alerts" {
  name = var.sns_topic_name

  tags = {
    Name    = "FileUploadAlerts"
    Project = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.file_upload_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}