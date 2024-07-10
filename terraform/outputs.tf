
output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.poc.domain_name}"
}

output "apigateway_url" {
  value = aws_apigatewayv2_api.poc.api_endpoint
}
