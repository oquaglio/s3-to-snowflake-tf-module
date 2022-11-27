variable "stack_context" {
  type = object({
    stack_name  = string
    environment = string
    owner       = string
    tags        = map(string)
  })
}


variable "aws_context" {
  type = object({
    profile     = string
    region      = string
    region_code = string # short code for region
  })
}


variable "snowflake_context" {
  type = object({
    warehouse        = string
    wh_size          = string
    schema           = string
    database         = string
    username         = string
    account          = string
    account_arn      = string
    external_id      = string
    role             = string
    private_key_path = string
    region           = string
  })
}