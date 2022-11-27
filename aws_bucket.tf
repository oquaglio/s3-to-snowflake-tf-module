locals {
  #bucket_postfix = "${data.aws_caller_identity.current.account_id}-${var.aws_region_code}"
  bucket_postfix = "${data.aws_caller_identity.current.account_id}-${var.aws_context["region_code"]}"
  bucket_name    = "${var.stack_context["stack_name"]}-s3-${local.bucket_postfix}-${var.stack_context["environment"]}"
}

#Create an encrypted bucket and restrict access from public
resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = var.stack_context["tags"]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object" {
  bucket   = aws_s3_bucket.this.id
  for_each = toset(var.bucket_object_prefixes)
  key      = each.value
}
