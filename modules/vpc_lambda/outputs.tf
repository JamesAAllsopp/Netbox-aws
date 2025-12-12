output "vpc" {
  value = module.vpc
}

output "sg" {
  value = {
    lb = module.lambda_sg.security_group.id
    db = module.db_sg.security_group.id
  }
}
