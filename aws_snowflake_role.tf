// Template file for Trust policy; This will allow Snowflake to assume the AWS role
data "template_file" "snowflake_load_trust_policy_template" {
  template = file("${path.module}/policies/snowflake_load_trust_policy.json")
  vars = {
    snowflake_account_arn = "${snowflake_storage_integration.this.storage_aws_iam_user_arn}"
    snowflake_external_id = "${snowflake_storage_integration.this.storage_aws_external_id}"
  }
}

// AWS Role with assume role policy
resource "aws_iam_role" "this" {
  name               = "${var.stack_context["stack_name"]}-snowflake-role-${var.stack_context["environment"]}"
  description        = "AWS role for Snowflake"
  assume_role_policy = data.template_file.snowflake_load_trust_policy_template.rendered
  tags               = var.stack_context["tags"]
}

// Template file for Permission Policy. This allows read access to target S3 buckets
data "template_file" "snowflake_load_policy_template" {
  template = file("${path.module}/policies/snowflake_load_policy.json")
  vars = {
    bucket_name = local.bucket_name
  }
}

// Create a Policy with permission to read target S3 buckets using the policy template
resource "aws_iam_policy" "this" {
  name        = "${var.stack_context["stack_name"]}-snowflake-access-${var.stack_context["environment"]}"
  description = "Allow authorised snowflake users to list files, read from S3 bucket."
  policy      = data.template_file.snowflake_load_policy_template.rendered
}

// Attach the permission policy to the AWS Role
resource "aws_iam_role_policy_attachment" "role_for_snowflake_load_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
