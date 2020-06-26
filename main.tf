provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current_acct" {}

resource "random_string" "rand" {
  length = 10
  special = false
  upper = false
}

### S3 bucket setup ###
resource "aws_s3_bucket" "web" {
  bucket = "web-${data.aws_caller_identity.current_acct.account_id}-${random_string.rand.result}"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
  enabled = true
  }
}

resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.web.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "publicAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.web.id}/*"
    }
  ]
}
POLICY
}


### Lambda setup ###
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda_execution_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "role_policy" {
  policy = data.aws_iam_policy_document.lambda_execution_role_policy.json
  name = "hackathon-lambda-execution-policy-${random_string.rand.result}"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "hackathon-lambda-role-${random_string.rand.result}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_custom_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.role_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_rds_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_vpc_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_lambda_function" "lambda_function" {
  filename      = var.lambda_zip_file
  function_name = "ffi-get-api-${random_string.rand.result}"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "com.ffi.service.InventoryService::handleRequest"
  source_code_hash = filebase64sha256(var.lambda_zip_file)
  timeout = "300"

  runtime = "java8"
  vpc_config {
    subnet_ids = var.subnets
    security_group_ids = [var.security_group_id]
  }
}


resource "aws_lambda_permission" "lambda_invoke_permissions" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.get_http_api.execution_arn}/*/*${var.api_route}"
}


### HTTP API Gateway Setup ###
resource "aws_apigatewayv2_api" "get_http_api" {
  name          = "ffi-get-api-${random_string.rand.result}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "OPTIONS"]
  }
  target = aws_lambda_function.lambda_function.arn
}

resource "aws_apigatewayv2_stage" "get_http_api_stage" {
  api_id = aws_apigatewayv2_api.get_http_api.id
  name   = "default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "get_http_integration" {
  api_id           = aws_apigatewayv2_api.get_http_api.id
  integration_type = "AWS_PROXY"
  integration_method  = "ANY"
  integration_uri           = aws_lambda_function.lambda_function.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_http_route" {
  api_id    = aws_apigatewayv2_api.get_http_api.id
  route_key = "ANY ${var.api_route}"
  target = "integrations/${aws_apigatewayv2_integration.get_http_integration.id}"
}
