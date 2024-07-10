resource "aws_apigatewayv2_api" "poc" {
  name                         = "${local.env_prefix}-poc-http-api"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
}

resource "aws_apigatewayv2_stage" "poc" {
  api_id      = aws_apigatewayv2_api.poc.id
  name        = "poc"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 100
  }
  route_settings {
    route_key              = aws_apigatewayv2_route.log_ingest.route_key
    logging_level          = "INFO"
    throttling_burst_limit = 100
    throttling_rate_limit  = 100
  }
}

resource "aws_apigatewayv2_authorizer" "drain_token" {
  api_id                            = aws_apigatewayv2_api.poc.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.drain_authorizer.invoke_arn
  identity_sources                  = ["$request.header.logplex-drain-token"]
  name                              = "${local.env_prefix}-drain-token-authorizer"
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 3600
  enable_simple_responses           = true
}

resource "aws_apigatewayv2_deployment" "poc" {
  api_id      = aws_apigatewayv2_api.poc.id
  description = "poc deployment"

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.log_ingest),
      jsonencode(aws_apigatewayv2_route.log_ingest),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_route" "log_ingest" {
  api_id             = aws_apigatewayv2_api.poc.id
  route_key          = "POST /logs"
  target             = "integrations/${aws_apigatewayv2_integration.log_ingest.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.drain_token.id
  authorization_type = "CUSTOM"
}

resource "aws_apigatewayv2_integration" "log_ingest" {
  api_id                 = aws_apigatewayv2_api.poc.id
  integration_type       = "AWS_PROXY"
  description            = "Lambda poc"
  integration_method     = "POST"
  integration_uri        = module.log_ingest.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}
