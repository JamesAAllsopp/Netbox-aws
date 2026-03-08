variable "namespace" {
    type = string
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-2"
  type        = string
}

variable "admin_user" {
  description = "Name of the RDS admin user"
  default     = "admintf"
  type        = string

}

variable "netbox_user" {
  description = "Name of the RDS admin user"
  default     = "netbox_user"
  type        = string

}
