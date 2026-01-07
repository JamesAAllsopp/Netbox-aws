variable "namespace" {
    type = string
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}

variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "elasticache_subnets" {
  description = "elasticache_subnets"
  type = list
}
