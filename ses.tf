variable "admin_email" {
  description = "Email address to verify for SES (Sender and Receiver for notifications)"
  type        = string
  default     = "admin@megastore.local" # REPLACE WITH REAL EMAIL
}

resource "aws_ses_email_identity" "admin" {
  email = var.admin_email
}
