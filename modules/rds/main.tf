resource "aws_db_subnet_group" "db_subnets" {
  name       = "db_subnets_group"
  subnet_ids = var.vpc_subnets

  tags = {
    Name = "Netbox"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  identifier           = "netbox-db"
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = "db.t3.micro"
  username             = "admintf"
  password             = var.db_secrets["password"]
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
}
