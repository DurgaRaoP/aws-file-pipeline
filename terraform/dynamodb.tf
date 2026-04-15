resource "aws_dynamodb_table" "file_metadata" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "filename"
  range_key    = "upload_timestamp"

  attribute {
    name = "filename"
    type = "S"
  }

  attribute {
    name = "upload_timestamp"
    type = "S"
  }

  tags = {
    Name    = "FileMetadataTable"
    Project = var.project_name
  }
}