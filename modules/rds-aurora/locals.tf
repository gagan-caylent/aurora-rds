locals {
  logs_set = compact([
    var.enable_postgresql_log ? "postgresql" : "",
  ])
}