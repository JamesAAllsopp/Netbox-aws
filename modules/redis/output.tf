output "redis_primary_endpoint" {
  description = "The DNS name of the primary write endpoint"
  value       = aws_elasticache_replication_group.netbox_redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "The DNS name of the reader endpoint"
  value       = aws_elasticache_replication_group.netbox_redis.reader_endpoint_address
}
