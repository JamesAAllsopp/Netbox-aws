output "db_address" {
  value = aws_db_instance.default.address
  description = "The DNS Endpoint address of the primary RDS database instance"
}
