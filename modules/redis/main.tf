resource "aws_security_group" "allow_redis" {
  name        = "allow_redis"
  description = "Allow redis inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_rds_postgress"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_redis_subneta" {
  security_group_id = aws_security_group.allow_redis.id
  cidr_ipv4         = var.cidra
  from_port         = 6379 
  ip_protocol       = "tcp"
  to_port           = 6379
}
resource "aws_vpc_security_group_ingress_rule" "allow_redis_subnetb" {
  security_group_id = aws_security_group.allow_redis.id
  cidr_ipv4         = var.cidrb
  from_port         = 6379
  ip_protocol       = "tcp"
  to_port           = 6379
}

resource "aws_vpc_security_group_egress_rule" "allow_redis_egress" {
  security_group_id = aws_security_group.allow_redis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol          = "-1"
}

resource "aws_elasticache_subnet_group" "redis_subnets" {
  name       = "redis-subnets-group"
  subnet_ids = var.vpc_subnets

  tags = {
    Name = "Netbox"
  }
}

#resource "aws_elasticache_cluster" "netbox_redis" {
#  cluster_id           = "netbox-redis"
#  engine               = "valkey"
#  node_type            = "cache.m6g.large"  #m4 doesn't support newest engines#.
#  num_cache_nodes      = 1
#  parameter_group_name = "default.valkey8"
#  engine_version       = "8.2"
#  port                 = 6379
#  subnet_group_name    = aws_elasticache_subnet_group.redis_subnets.name
#  security_group_ids   = [aws_security_group.allow_redis.id]
#}
resource "aws_elasticache_replication_group" "netbox_redis" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["eu-west-2a", "eu-west-2c"]
  replication_group_id        = "tf-rep-group-1"
  description                 = "netbox-redis"
  node_type                   = "cache.m6g.large"
  num_cache_clusters          = 2
  engine                      = "valkey"
  parameter_group_name        = "default.valkey8"
  port                        = 6379
  subnet_group_name           = aws_elasticache_subnet_group.redis_subnets.name
  security_group_ids          = [aws_security_group.allow_redis.id]
}
