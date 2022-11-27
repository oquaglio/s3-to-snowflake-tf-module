output "workspace" {
  value = terraform.workspace
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "stack_context" {
  value = var.stack_context
}

output "aws_context" {
  value = var.aws_context
}

output "snowflake_context" {
  value = var.snowflake_context
}

output aws_s3_bucket_id {
    value = aws_s3_bucket.this.id
}