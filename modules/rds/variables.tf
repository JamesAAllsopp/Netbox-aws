variable "namespace" {
    type = string
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}

variable "db_secrets" {
  description = "DB credentials"
  type = map
}

variable "vpc_subnets" {
  description = "The subnet the DB should be put in"
  type = list
}
