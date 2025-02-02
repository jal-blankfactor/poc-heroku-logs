locals {
  env_prefix     = "${var.env_level}-${var.env_name}"
  qualified_name = "${local.env_prefix}-${var.short_name}"
  src_dir        = "${path.cwd}/${var.app_dir}/dist"
  build_dir      = "${path.cwd}/${var.app_dir}/build"
}

resource "null_resource" "build" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "${path.cwd}/${var.app_dir}"
    command     = "npm run build"
  }
}

data "archive_file" "self" {
  type        = "zip"
  source_dir  = local.src_dir
  output_path = "${local.build_dir}/handler.zip"
  depends_on = [
    null_resource.build
  ]
}

resource "aws_lambda_function" "self" {
  filename      = "${local.build_dir}/handler.zip"
  function_name = local.qualified_name
  role          = aws_iam_role.self.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.self.output_base64sha256
  runtime          = var.runtime

  environment {
    variables = var.env_vars
  }

  layers = []

  depends_on = [
    data.archive_file.self
  ]

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_iam_role" "self" {
  name_prefix = local.qualified_name

  managed_policy_arns = concat(["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"], var.policy_arns)
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

