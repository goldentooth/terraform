data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "dynamic_dns" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/${var.zone_id}"]
  }

  statement {
    actions = [
      "ssm:GetParameter",
    ]
    resources = [aws_ssm_parameter.credentials.arn]
  }

  statement {
    actions = [
      "kms:Decrypt",
    ]
    resources = [data.aws_kms_key.ssm_default.arn]
  }
}

resource "aws_iam_policy" "dynamic_dns" {
  name   = "goldentooth-cluster-dynamic-dns"
  policy = data.aws_iam_policy_document.dynamic_dns.json
}

resource "aws_iam_role" "dynamic_dns_lambda" {
  name               = "goldentooth-cluster-dynamic-dns-lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "dynamic_dns" {
  for_each = {
    basic_execution = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    dynamic_dns     = aws_iam_policy.dynamic_dns.arn,
  }

  role       = aws_iam_role.dynamic_dns_lambda.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "api_gateway_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "apigateway.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "lambda_assume_api_gateway" {
  name               = "goldentooth-cluster-dynamic-dns-api-gateway"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume.json
}
