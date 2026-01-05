output "db_creds" {
  value = local.db_password_map
  sensitive = true
}
