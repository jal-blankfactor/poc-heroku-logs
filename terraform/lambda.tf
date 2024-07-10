module "log_ingest" {
  source       = "./lambda"
  env_level    = local.env_level
  env_name     = local.env_name
  short_name   = "log-ingest"
  display_name = "Log Ingest"
  app_dir      = "log-ingest"
  runtime      = "nodejs20.x"
}

module "drain_authorizer" {
  source = "./lambda"

  env_level    = local.env_level
  env_name     = local.env_name
  short_name   = "drain-authorizer"
  display_name = "Drain Authorizer"
  app_dir      = "drain-authorizer"
  policy_arns  = [aws_iam_policy.drain_authorizer.arn]
  runtime      = "nodejs20.x"
  env_vars = {
    DRAIN_TOKEN_PARAM_NAME = local.drain_token_param_name
  }
}

resource "aws_iam_policy" "drain_authorizer" {
  name_prefix = "${local.env_prefix}-policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.drain_authorizer.json
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "drain_authorizer" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "kms:Decrypt"]
    resources = [aws_ssm_parameter.drain_token.arn]
  }
}
