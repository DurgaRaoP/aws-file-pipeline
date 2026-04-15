import json
import boto3
import urllib.parse
import os
import logging
from datetime import datetime

# Setup structured logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS clients
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
sns_client = boto3.client('sns', region_name='ap-south-1')

# Environment variables
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE', 'file-pipeline-metadata')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN', '')

def lambda_handler(event, context):
    logger.info(json.dumps({
        "event": "lambda_triggered",
        "message": "Lambda triggered - processing S3 event",
        "request_id": context.aws_request_id
    }))

    try:
        # Extract S3 info from event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        file_key = urllib.parse.unquote_plus(
            event['Records'][0]['s3']['object']['key']
        )
        file_size = event['Records'][0]['s3']['object']['size']

        logger.info(json.dumps({
            "event": "file_received",
            "bucket": bucket_name,
            "file_key": file_key,
            "file_size_bytes": file_size
        }))

        # Get file metadata from S3
        s3_response = s3_client.head_object(Bucket=bucket_name, Key=file_key)
        content_type = s3_response.get('ContentType', 'unknown')
        upload_time = datetime.utcnow().isoformat()

        # Write metadata to DynamoDB
        table = dynamodb.Table(DYNAMODB_TABLE)
        table.put_item(
            Item={
                'filename': file_key,
                'upload_timestamp': upload_time,
                'bucket_name': bucket_name,
                'file_size_bytes': file_size,
                'content_type': content_type,
                'processing_status': 'SUCCESS'
            }
        )

        logger.info(json.dumps({
            "event": "dynamodb_write_success",
            "table": DYNAMODB_TABLE,
            "filename": file_key
        }))

        # Publish SNS notification
        if SNS_TOPIC_ARN:
            message = f"""
New file uploaded to pipeline!

File Name    : {file_key}
Bucket       : {bucket_name}
File Size    : {file_size} bytes
Content Type : {content_type}
Upload Time  : {upload_time}
Status       : SUCCESS
            """
            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=f"File Upload Alert - {file_key}",
                Message=message
            )

            logger.info(json.dumps({
                "event": "sns_notification_sent",
                "topic_arn": SNS_TOPIC_ARN,
                "filename": file_key
            }))

        logger.info(json.dumps({
            "event": "processing_complete",
            "filename": file_key,
            "status": "SUCCESS"
        }))

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File processed successfully',
                'filename': file_key,
                'status': 'SUCCESS'
            })
        }

    except Exception as e:
        logger.error(json.dumps({
            "event": "processing_failed",
            "error": str(e),
            "status": "FAILED"
        }))

        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'File processing failed',
                'error': str(e),
                'status': 'FAILED'
            })
        }
