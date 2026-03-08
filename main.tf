
# Can't create our own subnets in our shared VPC; see msg from Anthony on the 20th Janaury
#resource "aws_subnet" "main" {
#  vpc_id     = var.vpc_id
#  cidr_block = "172.19.6.96/28"
#  map_public_ip_on_launch = false
#
 # tags = {
#    Name = "DatabaseSubnet"
#  }
#}

#module "vpc_lambda" {
#  source    = "./modules/vpc_lambda"
#  namespace = var.namespace
#}

# Could call this from the root, but currently on
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

module "kms_secrets" {
  source    = "./modules/kms_secrets"
  namespace = var.namespace
}

module "rds" {
  source       = "./modules/rds"
  db_secrets   = module.kms_secrets.db_creds
  vpc_subnets  = tolist(["subnet-0d274c8027b86e0e3","subnet-0230bf131afb0a515"]) #module.vpc_lambda.vpc.database_subnets
  namespace    = var.namespace
  cidra        = "172.19.6.80/28"
  cidrb        = "172.19.6.64/28"
  vpc_id       = var.vpc_id
}

module "lambda"{
  source       = "./modules/lambda"
  namespace = var.namespace
  region = var.region
  rds_address = module.rds.db_address
  database_access_creds =  "database_access_creds"  #Should use a name from the aws_secretsmanager_secret resource.

  aws_account_id =  data.aws_caller_identity.current.account_id
}

module "redis" {
  source      = "./modules/redis"
  namespace   = var.namespace
  vpc_id      = var.vpc_id
  cidra       = "172.19.6.80/28"
  cidrb       = "172.19.6.64/28"
  vpc_subnets = tolist(["subnet-0d274c8027b86e0e3","subnet-0230bf131afb0a515"])
  #elasticache_subnets = module.vpc_lambda.vpc.elasticache_subnets
}
