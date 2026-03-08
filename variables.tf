variable "namespace" {
  type = string
  default = "test"
}

variable "vpc_id" {
  type = string
  default = "vpc-006b5d6ab57ef0d09"
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}
