# DynamoDB Privada (Acceso solo por IAM)
resource "aws_dynamodb_table" "usuarios" {
  name         = "usuarios-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "Dev"
    Project     = "RetoServerless"
  }
}

# SQS
resource "aws_sqs_queue" "user_queue" {
  name = "user-creation-queue"
}

# SNS
resource "aws_sns_topic" "user_notifications" {
  name = "user-notifications-topic"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.user_notifications.arn
  protocol  = "email"
  endpoint  = "jerson.garcia@pragma.com.co"
}