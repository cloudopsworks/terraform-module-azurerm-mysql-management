##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "mysql_database" "this" {
  for_each              = var.databases
  name                  = try(each.value.name, each.key)
  default_character_set = try(each.value.charset, "utf8mb4")
  default_collation     = try(each.value.collation, "utf8mb4_unicode_ci")
}

resource "random_password" "owner" {
  for_each         = { for k, v in var.users : k => v if try(v.access, "owner") == "owner" }
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  keepers = {
    rotation = var.password_rotation_period
    reset    = var.force_reset
  }
}

resource "mysql_user" "owner" {
  for_each           = { for k, v in var.users : k => v if try(v.access, "owner") == "owner" }
  user               = try(each.value.username, each.key)
  host               = try(each.value.host, "%")
  plaintext_password = random_password.owner[each.key].result
}

resource "mysql_grant" "owner" {
  for_each = {
    for item in flatten([
      for k, v in var.users : [
        for db in try(v.databases, []) : {
          key      = "${k}-${db}"
          username = try(v.username, k)
          host     = try(v.host, "%")
          database = db
        }
      ] if try(v.access, "owner") == "owner"
    ]) : item.key => item
  }
  user       = each.value.username
  host       = each.value.host
  database   = each.value.database
  privileges = ["ALL"]
  depends_on = [mysql_user.owner, mysql_database.this]
}
