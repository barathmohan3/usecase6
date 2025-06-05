data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.handler_file
  output_path = "${path.module}/../../${var.function_name}.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = var.role_arn
  handler          = var.handler_name
  runtime          = "python3.11"

  environment {
    variables = var.environment_vars
  }
}