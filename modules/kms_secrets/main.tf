resource "random_password" "db_password" {
  length           = 16
  special         = true
  upper           = true
  lower           = true
  numeric         = true
  override_special = "!@#%^&*"
}

resource "random_password" "netbox_password" {
  length           = 16
  special         = true
  upper           = true
  lower           = true
  numeric         = true
  override_special = "!@#%^&*"
}

locals {
  # This map now correctly references the resource output
  db_password_map = {
    username = "admin"
    password = random_password.db_password.result # Allowed in 'locals'
  }

  netbox_password_map = {
    username = "netboxadmin"
    password = random_password.netbox_password.result # Allowed in 'locals'
  }
}

resource "aws_secretsmanager_secret" "db_creds" {
  name = "database_access_creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode(local.db_password_map)
}

resource "aws_secretsmanager_secret" "netbox_creds" {
  name = "netbox_access_creds"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "netbox_creds_version" {
  secret_id     = aws_secretsmanager_secret.netbox_creds.id
  secret_string = jsonencode(local.netbox_password_map)
}
