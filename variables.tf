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
    warehouse = string
    wh_size   = string
    schema    = string
    database  = string
    username  = string
    account   = string
    #account_arn      = string
    #external_id      = string
    role             = string
    private_key_path = string
    region           = string
  })
}


variable "bucket_object_prefixes" {
  description = "List of bucket object prefixes to create"
  type        = set(string)
  default     = ["landing/", "processed/", "archived/"]
}


variable "sources" {
  type = list(object({
    name    = string
    comment = string
    fields = list(object({
      name     = string
      type     = string
      nullable = bool
      source   = string
    }))
    primary_key   = set(string)
    s3_key_prefix = string
  }))
}

# variable "bucket_key_prefixes_for_tables" {
#   type = map(any)
# }
