resource "snowflake_warehouse" "this" {
  name           = var.snowflake_context["warehouse"]
  warehouse_size = var.snowflake_context["wh_size"]

  auto_suspend = 60
}

resource "snowflake_database" "this" {
  name                        = upper("${var.stack_context["environment"]}")
  comment                     = upper("${var.stack_context["environment"]} database")
  data_retention_time_in_days = 3
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = "RAW_MOVIE"
  comment  = "Schema for RAW movie data"

  is_transient        = false
  is_managed          = false
  data_retention_days = 1
}

resource "snowflake_table" "this" {
  for_each = { for tbl in var.sources : tbl.name => tbl }

  database            = snowflake_schema.this.database
  schema              = snowflake_schema.this.name
  data_retention_days = snowflake_schema.this.data_retention_days
  change_tracking     = false
  name                = each.key
  comment             = lookup(each.value, "comment", null)

  dynamic "column" { # can add multiple instances of this
    for_each = { for fld in each.value.fields : fld.name => fld }

    content {
      name = column.value.name
      type = column.value.type
      # set defaults on the following attr if missing
      comment  = lookup(column.value, "comment", null)
      nullable = lookup(column.value, "nullable", true)
    }
  }
}

// apply primary keys
resource "snowflake_table_constraint" "primary_keys" {
  for_each = {
    for tbl in snowflake_table.this : tbl.name => tbl
    # skip table if no primary key defined
    if try(lookup(var.sources[index(var.sources.*.name, tbl.name)], "primary_key", false)) != false
  }

  name     = "PRIMARY_KEY_CONSTRAINT"
  type     = "PRIMARY KEY"
  table_id = each.value.id
  columns  = var.sources[index(var.sources.*.name, each.value.name)].primary_key
  comment  = "Primary key for ${var.sources[index(var.sources.*.name, each.value.name)].name} table"
}

resource "snowflake_tag" "tag" {
  name           = "cost_center"
  database       = snowflake_schema.this.database
  schema         = snowflake_schema.this.name
  allowed_values = ["finance", "engineering"]
}
