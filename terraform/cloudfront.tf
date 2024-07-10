locals {
  origin_id  = "${local.env_prefix}-poc"
  region     = data.aws_region.current
  api_domain = replace(aws_apigatewayv2_api.poc.api_endpoint, "https://", "")
}

resource "aws_cloudfront_distribution" "poc" {
  web_acl_id = aws_wafv2_web_acl.poc.arn
  origin {
    domain_name = local.api_domain
    origin_id   = local.origin_id
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
