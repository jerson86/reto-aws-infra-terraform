resource "aws_apigatewayv2_api" "api" {
  name          = "usuarios-api-unica"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "dev"
  auto_deploy = true
}

# --- INTEGRACIONES  ---

resource "aws_apigatewayv2_integration" "get_int" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.get_users.invoke_arn
}

resource "aws_apigatewayv2_integration" "post_int" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_user.invoke_arn
}

resource "aws_apigatewayv2_integration" "put_int" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.update_user.invoke_arn
}

resource "aws_apigatewayv2_integration" "delete_int" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.delete_user.invoke_arn
}

# --- RUTAS ---

resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /usuarios"
  target    = "integrations/${aws_apigatewayv2_integration.get_int.id}"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /usuarios"
  target    = "integrations/${aws_apigatewayv2_integration.post_int.id}"
}

resource "aws_apigatewayv2_route" "put_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "PUT /usuarios/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.put_int.id}"
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "DELETE /usuarios/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_int.id}"
}

# --- PERMISOS  ---

resource "aws_lambda_permission" "apigw_get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_post" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_put" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_delete" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}