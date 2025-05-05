resource "aws_apigatewayv2_api" "dynamic_dns" {
  name          = "GoldenTooth Cluster Dynamic DNS"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "dynamic_dns" {
  api_id                 = aws_apigatewayv2_api.dynamic_dns.id
  integration_type       = "AWS_PROXY"
  description            = "Update Dynamic DNS"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.dynamic_dns.arn
  payload_format_version = "2.0"

  lifecycle {
    ignore_changes = [passthrough_behavior]
  }
}

resource "aws_apigatewayv2_route" "dynamic_dns" {
  api_id    = aws_apigatewayv2_api.dynamic_dns.id
  route_key = "GET /nic/update"
  target    = "integrations/${aws_apigatewayv2_integration.dynamic_dns.id}"
}

resource "aws_apigatewayv2_domain_name" "dynamic_dns" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.dynamic_dns.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.dynamic_dns.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_api_mapping" "dynamic_dns" {
  api_id      = aws_apigatewayv2_api.dynamic_dns.id
  domain_name = aws_apigatewayv2_domain_name.dynamic_dns.id
  stage       = aws_apigatewayv2_stage.default.id
}
