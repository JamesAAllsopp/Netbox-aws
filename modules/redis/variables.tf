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

variable "vpc_subnets" {
  description = "The subnet the DB should be put in"
  type = list
}

variable "cidra" {
    type = string
}

variable "cidrb"{
    type = string
}

