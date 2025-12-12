output "db_creds_arn" {
  value =aws_secretsmanager_secret_version.db_creds_version.arn
}
