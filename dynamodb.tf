resource "aws_dynamodb_table" "usuarios" {
  name           = "${var.project_name}-usuarios"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "aws_dynamodb_table" "productos" {
  name           = "${var.project_name}-productos"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "product_id"

  attribute {
    name = "product_id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "aws_dynamodb_table" "compras" {
  name             = "${var.project_name}-compras"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "purchase_id"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "purchase_id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}

resource "aws_dynamodb_table" "busquedas" {
  name           = "${var.project_name}-busquedas"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "search_id"

  attribute {
    name = "search_id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}
