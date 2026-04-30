##
# (c) 2021-2026
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

## YAML Input Format
# users:
#   owner:                           # (Required) Key is the logical user name
#     username: "appowner"           # (Required) MySQL user name
#     host: "%"                      # (Optional) MySQL host. Default: "%"
#     databases: ["mydb"]            # (Required) List of databases to grant access
#     access: "owner"                # (Optional) owner/readwrite/readonly. Default: "owner"
#     hoop:                             # (Optional) Per-user Hoop settings.
#       access_control: []              # (Optional) Access control groups merged with hoop.access_control.
variable "users" {
  description = "Map of MySQL users to create with their database assignments."
  type        = any
  default     = {}
}

## YAML Input Format
# databases:
#   mydb:                            # (Required) Key is the logical database name
#     name: "mydb"                   # (Required) Actual database name
#     charset: "utf8mb4"             # (Optional) Character set. Default: "utf8mb4"
#     collation: "utf8mb4_unicode_ci" # (Optional) Collation. Default: "utf8mb4_unicode_ci"
variable "databases" {
  description = "Map of MySQL databases to create."
  type        = any
  default     = {}
}

## YAML Input Format
# hoop:
#   enabled: false                   # (Optional) Enable Hoop connection output. Default: false.
#   community: true                  # (Optional) true=null output; false=enterprise. Default: true.
#   agent_id: ""                     # (Required when enabled+enterprise) Hoop agent UUID.
#   port: 3307                       # (Optional) Local port for Hoop tunnel mode. Default: 3307.
#   db_name: "mysql"                 # (Optional) Database for hoop tunnel connection.
#   server_name: ""                  # (Optional) Server name for hoop tunnel mode.
#   import: false                    # (Optional) Import existing connection. Default: false.
#   tags: {}                         # (Optional) Tags for Hoop connections.
#   access_control: []               # (Optional) Access control groups.
variable "hoop" {
  description = "Hoop connection configuration. Enterprise mode stores per-field secrets in Key Vault."
  type        = any
  default     = {}
}

## YAML Input Format
# azure:
#   enabled: false                   # (Optional) Connect via Azure MySQL Flexible Server. Default: false.
#   from_secret: false               # (Optional) Read credentials from Key Vault secret. Default: false.
#   secret_name: ""                  # (Required when from_secret=true) KV secret name containing JSON credentials.
#   server_name: ""                  # (Required when enabled+!from_secret) Flexible Server name.
#   resource_group_name: ""          # (Optional) Resource group of server.
#   admin_username: "adminuser"      # (Optional) Admin username. Default: "adminuser".
#   admin_password: ""               # (Optional) Admin password.
#   db_name: "mysql"                 # (Optional) Default database. Default: "mysql".
#   sslmode: "true"                  # (Optional) TLS mode. Default: "true".
variable "azure" {
  description = "Azure MySQL Flexible Server connection settings. Mutually exclusive with direct/hoop."
  type        = any
  default     = {}
}

## YAML Input Format
# direct:
#   host: ""                         # (Required) MySQL server hostname or IP.
#   port: 3306                       # (Optional) Port. Default: 3306.
#   username: ""                     # (Required) Admin username.
#   password: ""                     # (Required) Admin password.
#   db_name: "mysql"                 # (Optional) Default database. Default: "mysql".
#   server_name: ""                  # (Optional) Logical server name.
#   tls: "true"                      # (Optional) TLS. Default: "true".
variable "direct" {
  description = "Direct MySQL connection settings. Used when azure.enabled=false and hoop.enabled=false."
  type        = any
  default     = {}
}

## YAML Input Format
# password_rotation_period: "30d"   # (Optional) Password rotation period. Default: "".
variable "password_rotation_period" {
  description = "(Optional) Password rotation period for user credentials (e.g., '30d'). Default: empty."
  type        = string
  default     = ""
}

## YAML Input Format
# force_reset: false
variable "force_reset" {
  description = "(Optional) Force password reset for all managed users on next apply. Default: false."
  type        = bool
  default     = false
}

## YAML Input Format
# key_vault_name: "my-keyvault"
variable "key_vault_name" {
  description = "(Required) Name of the existing Azure Key Vault for credential and hoop secret storage."
  type        = string
}

## YAML Input Format
# key_vault_resource_group_name: "rg-shared"
variable "key_vault_resource_group_name" {
  description = "(Required) Resource group name of the existing Azure Key Vault."
  type        = string
}
