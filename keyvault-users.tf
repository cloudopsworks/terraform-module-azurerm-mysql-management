##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

locals {
  kv_prefix = lower(replace(local.system_name_short, "/[^a-zA-Z0-9-]/", "-"))

  owner_credentials = {
    for k, v in var.users : k => {
      username    = try(v.username, k)
      password    = module.db.owner_passwords[k]
      host        = local.mysql_conn.host
      port        = local.mysql_conn.port
      databases   = try(v.databases, [])
      server_name = local.mysql_conn.server_name
    } if try(v.access, "owner") == "owner"
  }

  user_credentials = {
    for k, v in var.users : k => {
      username    = try(v.username, k)
      password    = module.db.user_passwords[k]
      host        = local.mysql_conn.host
      port        = local.mysql_conn.port
      databases   = try(v.databases, [])
      server_name = local.mysql_conn.server_name
    } if try(v.access, "owner") != "owner"
  }
}

resource "azurerm_key_vault_secret" "owner_credentials" {
  for_each     = local.owner_credentials
  name         = lower(replace("${local.kv_prefix}-mysql-${each.value.username}-creds", "/[^a-zA-Z0-9-]/", "-"))
  value        = jsonencode(each.value)
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "application/json"
  tags         = local.all_tags
}

resource "azurerm_key_vault_secret" "user_credentials" {
  for_each     = local.user_credentials
  name         = lower(replace("${local.kv_prefix}-mysql-${each.value.username}-creds", "/[^a-zA-Z0-9-]/", "-"))
  value        = jsonencode(each.value)
  key_vault_id = data.azurerm_key_vault.credentials.id
  content_type = "application/json"
  tags         = local.all_tags
}
