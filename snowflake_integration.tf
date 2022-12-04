locals {
  calculated_sf_iam_role_name = "${var.stack_context["stack_name"]}-snowflake-role-${var.stack_context["environment"]}"
  calculated_sf_iam_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.calculated_sf_iam_role_name}"
}

// Storage integration that assumes the AWS role created
resource "snowflake_storage_integration" "this" {
  name    = replace(upper("${var.stack_context["stack_name"]}_${var.aws_context["region_code"]}_s3_load_int"), "-", "_")
  comment = "Storage integration used to read files from S3 staging bucket"
  type    = "EXTERNAL_STAGE"

  enabled = true

  storage_provider = "S3"
  #storage_aws_role_arn = aws_iam_role.role_for_snowflake_load.arn
  storage_aws_role_arn = local.calculated_sf_iam_role_arn
  storage_allowed_locations = [
    "s3://${local.bucket_name}/"
  ]
}

resource "snowflake_file_format" "this" {
  name              = "JSON_FILE_FORMAT"
  database          = snowflake_database.this.name
  schema            = snowflake_schema.this.name
  format_type       = "JSON"
  binary_format     = "HEX"
  compression       = "AUTO"
  strip_outer_array = true
}

resource "snowflake_stage" "this" {
  name                = replace(upper("${var.stack_context["stack_name"]}_${var.aws_context["region_code"]}_ext_stage"), "-", "_")
  url                 = "s3://${local.bucket_name}"
  database            = snowflake_database.this.name
  schema              = snowflake_schema.this.name
  storage_integration = snowflake_storage_integration.this.name
  file_format         = "format_name = ${snowflake_database.this.name}.${snowflake_schema.this.name}.${snowflake_file_format.this.name}"
}

# data "template_file" "snowflake_pipe_copy_stmt" {
#   template = file("${path.module}/templates/copy.sql")
#   vars = {
#     snowflake_database = database
#     snowflake_schema = schema
#     table_name = each.value.name
#     field_list = merge(each.value.fields.name)
#     source_list = mearge(each.value.source)
#     snowflake_stage = snowflake_stage.this
#     s3_key_prefix_lvl_1 = "landing"
#     s3_key_prefix_lvl_2 = each.value.s3_key_prefix
#     snowflake_account_arn = "${snowflake_storage_integration.this.storage_aws_iam_user_arn}"
#     snowflake_external_id = "${snowflake_storage_integration.this.storage_aws_external_id}"
#   }
# }

resource "snowflake_pipe" "pipes" {
  #for_each = { for pipe in var.snowflake_pipes : pipe.name => pipe }
  for_each = { for src in var.sources : src.name => src }

  database = snowflake_database.this.name
  schema   = snowflake_schema.this.name
  #name     = replace(upper("${var.stack_name}_${var.aws_region_code}_${local.pipes[index(local.pipes.*.table, each.value.name)].name}"), "-", "_")
  name    = replace(upper("${var.stack_context["stack_name"]}_${var.aws_context["region_code"]}_${each.value.name}_PIPE"), "-", "_")
  comment = "Pipe to ingest files from bucket"

  #copy_statement = local.pipes[index(local.pipes.*.table, each.value.name)].copy_stmt
  #copy_statement = local.pipes[index(local.pipes.*.name, each.value.name)].copy_stmt
  #copy_statement = template_file.snowflake_pipe_copy_stmt.rendered
  copy_statement = templatefile("${path.module}/templates/copy.sql", {
    snowflake_database    = snowflake_database.this.name
    snowflake_schema      = snowflake_schema.this.name
    table_name            = each.value.name
    field_list            = join(", ", each.value.fields.*.name)
    source_list           = join(", ", each.value.fields.*.source)
    snowflake_stage       = snowflake_stage.this.name
    s3_key_prefix_lvl_1   = "landing"
    s3_key_prefix_lvl_2   = each.value.s3_key_prefix
    snowflake_account_arn = "${snowflake_storage_integration.this.storage_aws_iam_user_arn}"
    snowflake_external_id = "${snowflake_storage_integration.this.storage_aws_external_id}"
  })

  auto_ingest       = true
  aws_sns_topic_arn = aws_sns_topic.this.arn
  depends_on        = [aws_sns_topic.this, snowflake_stage.this, snowflake_storage_integration.this, aws_iam_role_policy_attachment.role_for_snowflake_load_policy_attachment]
}
