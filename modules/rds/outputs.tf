output "db_address" {
  value = aws_db_instance.default.address
  description = "The DNS Endpoint address of the primary RDS database instance"
}

output "rds_sg" {
  value = aws_security_group.allow_rds_postgress.id
  description = "The Security group id  (sg-[0-9a-zA-Z]*) allowing access to the RDS database"
}
