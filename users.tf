##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "random_password" "user" {
  for_each         = { for k, v in var.users : k => v if try(v.access, "owner") != "owner" }
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  keepers = {
    rotation = var.password_rotation_period
    reset    = var.force_reset
  }
}

resource "mysql_user" "user" {
  for_each           = { for k, v in var.users : k => v if try(v.access, "owner") != "owner" }
  user               = try(each.value.username, each.key)
  host               = try(each.value.host, "%")
  plaintext_password = random_password.user[each.key].result
}

resource "mysql_grant" "readwrite" {
  for_each = {
    for item in flatten([
      for k, v in var.users : [
        for db in try(v.databases, []) : {
          key      = "${k}-${db}"
          username = try(v.username, k)
          host     = try(v.host, "%")
          database = db
        }
      ] if try(v.access, "owner") == "readwrite"
    ]) : item.key => item
  }
  user       = each.value.username
  host       = each.value.host
  database   = each.value.database
  privileges = ["SELECT", "INSERT", "UPDATE", "DELETE"]
  depends_on = [mysql_user.user, mysql_database.this]
}

resource "mysql_grant" "readonly" {
  for_each = {
    for item in flatten([
      for k, v in var.users : [
        for db in try(v.databases, []) : {
          key      = "${k}-${db}"
          username = try(v.username, k)
          host     = try(v.host, "%")
          database = db
        }
      ] if try(v.access, "owner") == "readonly"
    ]) : item.key => item
  }
  user       = each.value.username
  host       = each.value.host
  database   = each.value.database
  privileges = ["SELECT"]
  depends_on = [mysql_user.user, mysql_database.this]
}
