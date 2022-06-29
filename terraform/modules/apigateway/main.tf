# API Gateway
resource "aws_apigatewayv2_api" "apigw" {
  name          = var.resource_name
  protocol_type = "HTTP"
  disable_execute_api_endpoint = true
  cors_configuration {
    allow_methods     = ["GET"]
    allow_origins     = ["https://nickcollins.link"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.apigw.id

  integration_uri    = var.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.apigw.id
  name        = "api"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id = aws_apigatewayv2_api.apigw.id

  route_key = "GET /incrementViewCount"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.apigw.execution_arn}/*/*"
}

resource "aws_apigatewayv2_domain_name" "apigw_domain" {
  domain_name = "api.${var.dns_root_name}"

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  api_id      = aws_apigatewayv2_api.apigw.id
  domain_name = aws_apigatewayv2_domain_name.apigw_domain.id
  stage       = aws_apigatewayv2_stage.stage.id
}

resource "aws_route53_record" "record" {
  name    = aws_apigatewayv2_domain_name.apigw_domain.domain_name
  type    = "A"
  zone_id = var.r53_zoneID

  alias {
    name                   = aws_apigatewayv2_domain_name.apigw_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.apigw_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
