data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach basic execution role (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom policy to access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "${var.project_name}-lambda-dynamodb-policy"
  description = "Permisos para Lambdas de acceder a DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = [
          aws_dynamodb_table.usuarios.arn,
          aws_dynamodb_table.productos.arn,
          aws_dynamodb_table.compras.arn,
          aws_dynamodb_table.busquedas.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}


# Lambda: Compra
resource "aws_lambda_function" "compra" {
  filename      = "dummy.zip"
  function_name = "${var.project_name}-compra"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      TABLE_COMPRAS = aws_dynamodb_table.compras.name
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

# Lambda: Busqueda
variable "gemini_api_key" {
  description = "Gemini API Key for recommendations"
  type        = string
  sensitive   = true
  default     = "sk-placeholder"
}

resource "aws_lambda_function" "busqueda" {
  filename      = "dummy.zip"
  function_name = "${var.project_name}-busqueda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      TABLE_PRODUCTOS = aws_dynamodb_table.productos.name
      TABLE_BUSQUEDAS = aws_dynamodb_table.busquedas.name
      GEMINI_API_KEY  = var.gemini_api_key
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

# Attach S3 policy
resource "aws_iam_policy" "lambda_s3" {
  name        = "${var.project_name}-lambda-s3-policy"
  description = "Permisos para Lambdas de acceder a S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.product_images.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

# Lambda: Productos
resource "aws_lambda_function" "productos" {
  filename      = "dummy.zip"
  function_name = "${var.project_name}-productos"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      TABLE_PRODUCTOS   = aws_dynamodb_table.productos.name
      BUCKET_IMAGES     = aws_s3_bucket.product_images.bucket
      CLOUDFRONT_DOMAIN = aws_cloudfront_distribution.cdn.domain_name
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

# Attach SES and DynamoDB Streams policy
resource "aws_iam_policy" "lambda_ses_streams" {
  name        = "${var.project_name}-lambda-ses-streams-policy"
  description = "Permisos para SES y DynamoDB Streams"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.compras.stream_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses_streams_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses_streams.arn
}

# Lambda: Notificaciones
resource "aws_lambda_function" "notificaciones" {
  filename      = "dummy.zip"
  function_name = "${var.project_name}-notificaciones"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  environment {
    variables = {
      ADMIN_EMAIL = var.admin_email
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

# DynamoDB Stream Trigger for Notificaciones
resource "aws_lambda_event_source_mapping" "compras_stream_mapping" {
  event_source_arn  = aws_dynamodb_table.compras.stream_arn
  function_name     = aws_lambda_function.notificaciones.arn
  starting_position = "LATEST"
}
