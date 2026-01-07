
module "vpc_lambda" {
  source    = "./modules/vpc_lambda"
  namespace = var.namespace
}

module "kms_secrets" {
  source    = "./modules/kms_secrets"
  namespace = var.namespace
}

module "rds" {
  source       = "./modules/rds"
  db_secrets   = module.kms_secrets.db_creds
  vpc_subnets  = module.vpc_lambda.vpc.database_subnets
  namespace    = var.namespace
}

module "lambda"{
  source       = "./modules/lambda"
}

module "redis" {
  source    = "./modules/redis"
  namespace = var.namespace
  vpc_id = module.vpc_lambda.vpc.vpc_id
  elasticache_subnets = module.vpc_lambda.vpc.elasticache_subnets
}
