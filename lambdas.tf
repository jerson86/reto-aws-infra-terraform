# --- NODEJS: GET & POST ---
resource "aws_lambda_function" "get_users" {
  function_name    = "getUsersNode"
  handler          = "getuser.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.role_get.arn
  filename         = "src/node/getuser.zip"
  source_code_hash = filebase64sha256("src/node/getuser.zip")
}

resource "aws_lambda_function" "create_user" {
  function_name = "postUsersNode"
  handler       = "postuser.handler"
  runtime       = "nodejs16.x"
  role          = aws_iam_role.role_post.arn
  filename      = "src/node/postuser.zip"
  environment {
    variables = {
      SQS_URL = aws_sqs_queue.user_queue.id
    }
  }
  source_code_hash = filebase64sha256("src/node/postuser.zip")
}

# --- JAVA: PUT & DELETE ---
resource "aws_lambda_function" "update_user" {
  function_name    = "putUsersJava"
  handler          = "com.reto.PutHandler::handleRequest"
  runtime          = "java11"
  role             = aws_iam_role.role_java_db.arn
  filename         = "src/java/usuarios-api.jar"
  memory_size      = 512
  timeout          = 20
  source_code_hash = filebase64sha256("src/java/usuarios-api.jar")
}

resource "aws_lambda_function" "delete_user" {
  function_name    = "deleteUsersJava"
  handler          = "com.reto.DeleteHandler::handleRequest"
  runtime          = "java11"
  role             = aws_iam_role.role_java_db.arn
  filename         = "src/java/usuarios-api.jar"
  memory_size      = 512
  timeout          = 20
  source_code_hash = filebase64sha256("src/java/usuarios-api.jar")
}

# --- LAMBDA NOTIFICADORA (SQS -> SNS) ---
resource "aws_lambda_function" "notifier" {
  function_name = "enviarCorreos"
  handler       = "notifier.handler"
  runtime       = "nodejs16.x"
  role          = aws_iam_role.role_notifier.arn # Agregar permiso de SNS Publish a este rol
  filename      = "src/node/notifier.zip"
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.user_notifications.arn
    }
  }
  source_code_hash = filebase64sha256("src/node/notifier.zip")
}

# Disparador SQS para la Lambda Notificadora
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.user_queue.arn
  function_name    = aws_lambda_function.notifier.arn
}