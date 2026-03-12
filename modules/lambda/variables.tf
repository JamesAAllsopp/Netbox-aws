variable "namespace" {
    type = string
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}

variable "rds_address" {
  description = "rds dns hostname"
  type        = string
}

variable "database_access_creds" {
  description = "name of the secrets"
  type        = string
}

variable "aws_account_id" {
  description = "aws account id"
  type        = string
}


variable "sg_rds" {
  description = "id of the security group"
  type        = string
}

variable "subnet" {
  description = "Subnet of the project"
  type        = string
}


