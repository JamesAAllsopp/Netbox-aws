
# Need this if trying to install into existing subnet; need to run it once, then comment it out.
#resource "aws_iam_service_linked_role" "rds" {
#  aws_service_name = "rds.amazonaws.com"
#}


#Doing things like this maybe why the old way doesn't work? I'm sure this can be neatened.
resource "aws_security_group" "allow_rds_postgress" {
  name        = "allow_rds_postgress"
  description = "Allow postgres inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_rds_postgress"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_rds_postgress_subneta" {
  security_group_id = aws_security_group.allow_rds_postgress.id
  cidr_ipv4         = var.cidra
  from_port         = 5432 
  ip_protocol       = "tcp"
  to_port           = 5432
}
resource "aws_vpc_security_group_ingress_rule" "allow_rds_postgress_subnetb" {
  security_group_id = aws_security_group.allow_rds_postgress.id
  cidr_ipv4         = var.cidrb
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "allow_rds_postgress_egress" {
  security_group_id = aws_security_group.allow_rds_postgress.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol          = "-1"
}

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
  vpc_security_group_ids = [aws_security_group.allow_rds_postgress.id] # Need this in a shared system.
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
}
