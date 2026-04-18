##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

provider "mysql" {
  endpoint = "${local.mysql_conn.host}:${local.mysql_conn.port}"
  username = local.mysql_conn.username
  password = local.mysql_conn.password
  tls      = local.mysql_conn.tls
}
