resource "aws_lambda_function" "dynamic_dns" {
  filename      = "${path.module}/placeholder.zip"
  function_name = "goldentooth-cluster-dynamic-dns"
  role          = aws_iam_role.dynamic_dns_lambda.arn
  handler       = "lambda.handler"
  runtime       = "python3.12"
  memory_size   = 2048
  timeout       = 5

  environment {
    variables = {
      HOSTED_ZONE_ID   = var.zone_id,
      CREDENTIALS_NAME = aws_ssm_parameter.credentials.name,
      DEFAULT_TTL      = var.default_ttl,
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_apig" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamic_dns.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.dynamic_dns.execution_arn}/*"
}
