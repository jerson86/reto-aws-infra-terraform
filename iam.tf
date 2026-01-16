locals {
  lambda_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "role_get" {
  name               = "role_lambda_get"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_role_policy" "policy_get" {
  name = "policy_get"
  role = aws_iam_role.role_get.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["dynamodb:Scan", "dynamodb:GetItem"], Effect = "Allow", Resource = aws_dynamodb_table.usuarios.arn },
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role" "role_post" {
  name               = "role_lambda_post"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_role_policy" "policy_post" {
  name = "policy_post"
  role = aws_iam_role.role_post.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["dynamodb:PutItem"], Effect = "Allow", Resource = aws_dynamodb_table.usuarios.arn },
      { Action = ["sqs:SendMessage"], Effect = "Allow", Resource = aws_sqs_queue.user_queue.arn },
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role" "role_java_db" {
  name               = "role_lambda_java_db"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_role_policy" "policy_java_db" {
  name = "policy_java_db"
  role = aws_iam_role.role_java_db.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["dynamodb:UpdateItem", "dynamodb:DeleteItem"], Effect = "Allow", Resource = aws_dynamodb_table.usuarios.arn },
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role" "role_notifier" {
  name               = "role_lambda_notifier"
  assume_role_policy = local.lambda_assume_role_policy
}

resource "aws_iam_role_policy" "policy_notifier" {
  name = "policy_notifier"
  role = aws_iam_role.role_notifier.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"], Effect = "Allow", Resource = aws_sqs_queue.user_queue.arn },
      { Action = ["sns:Publish"], Effect = "Allow", Resource = aws_sns_topic.user_notifications.arn },
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_sqs_queue_policy" "user_queue_policy" {
  queue_url = aws_sqs_queue.user_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.role_post.arn
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.user_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : aws_lambda_function.create_user.arn
          }
        }
      }
    ]
  })
}