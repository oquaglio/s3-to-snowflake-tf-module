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

output "aws_s3_bucket_id" {
  value = aws_s3_bucket.this.id
}

output "snowflake_pipes" {
  value = snowflake_pipe.pipes
}

output "snowflake_stage" {
  value     = snowflake_stage.this
  sensitive = true
}

output "snowflake_storage_integration" {
  value = snowflake_storage_integration.this
}

output "aws_s3_bucket_notification" {
  value = aws_s3_bucket_notification.this
}

output "snowflake_load_trust_policy_template" {
  value = data.template_file.snowflake_load_trust_policy_template
}

output "aws_iam_role" {
  value = aws_iam_role.this
}

output "snowflake_storage_aws_iam_user_arn" {
  value = snowflake_storage_integration.this.storage_aws_iam_user_arn
}



# output "actor_pk" {
#   value = try(lookup(var.sources[index(var.sources.*.name, "ACTOR")], "primary_key", "blah"))
# }

# output "sources_actor" {
#   value = var.sources[index(var.sources.*.name, "ACTOR")]
# }

# output "actor_pk_map" {
#   value = lookup(var.sources[index(var.sources.*.name, "ACTOR")], "primary_key", null) != null
# }

# output "does_actor_have_pk" {
#   value = try(lookup(var.sources[index(var.sources.*.name, "ACTOR")], "primary_key", false)) != false
# }