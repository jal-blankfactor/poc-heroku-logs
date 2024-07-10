data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  org                    = var.org
  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_region             = data.aws_region.current.name
  env_level              = "le"
  env_name               = "dev"
  devops_prefix          = "${local.org}-ops"
  env_prefix             = "${local.env_level}-${local.env_name}"
  drain_token_param_name = "/${local.env_name}/log-ingest/drain-token"
}

# API GW <-> Lambda
resource "aws_lambda_permission" "invoke_log_ingest" {
  statement_id  = "FunctionInvokePostLogs"
  action        = "lambda:InvokeFunction"
  function_name = module.log_ingest.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.poc.execution_arn}/*/*/logs"
}

resource "aws_lambda_permission" "invoke_drain_authorizer" {
  statement_id  = "FunctionInvokeDrainAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = module.drain_authorizer.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.poc.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.drain_token.id}"
}

# SSM params
# due to chicken and egg scenario + tf api gw oddity
resource "random_id" "placeholder_token" {
  byte_length = 16
}

resource "aws_ssm_parameter" "drain_token" {
  name        = local.drain_token_param_name
  description = "Heroku drain token"
  type        = "SecureString"
  value       = random_id.placeholder_token.hex
  lifecycle {
    ignore_changes = [value]
  }
}

# Secret manager
# resource "aws_secretsmanager_secret" "drain_token" {
#   name        = local.drain_token_param_name
#   description = "Heroku drain token"
# }
# resource "aws_secretsmanager_secret_version" "drain_token" {
#   secret_id     = aws_secretsmanager_secret.drain_token.id
#   secret_string = var.drain_token
# }

# S3
resource "random_id" "artifacts-bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "artifacts-bucket" {
  bucket = "${local.devops_prefix}-artifacts-${random_id.artifacts-bucket.hex}"
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
