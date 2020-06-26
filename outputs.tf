output "unique_identifier" {
  value = random_string.rand.id
}

output "s3_bucket" {
  value = aws_s3_bucket.web.id
}

output "get_api_endpoint" {
  value = aws_apigatewayv2_api.get_http_api.api_endpoint
}

output "lambda_role" {
  value = aws_iam_role.lambda_execution_role.name
}

output "lambda_function" {
  value = aws_lambda_function.lambda_function.function_name
}
