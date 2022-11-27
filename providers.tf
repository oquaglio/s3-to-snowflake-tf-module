
# modules to be downloaded
provider "aws" {
  profile = var.aws_context["profile"]
  region  = var.aws_context["region"]
}

provider "random" {}

provider "snowflake" {
  username         = var.snowflake_context["username"]
  account          = var.snowflake_context["account"]
  region           = var.snowflake_context["region"]
  private_key_path = var.snowflake_context["private_key_path"]
  #warehouse = var.snowflake_warehouse
}
