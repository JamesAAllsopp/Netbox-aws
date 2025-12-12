
module "vpc_lambda" {
  source    = "./modules/vpc_lambda"
  namespace = var.namespace
}


module "kms_secrets" {
  source    = "./modules/kms_secrets"
  namespace = var.namespace
}
