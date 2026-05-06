resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "product_images" {
  bucket = "${var.project_name}-images-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "product_images_public_access" {
  bucket = aws_s3_bucket.product_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_cloudfront_read" {
  bucket = aws_s3_bucket.product_images.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.product_images.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.product_images_public_access]
}
