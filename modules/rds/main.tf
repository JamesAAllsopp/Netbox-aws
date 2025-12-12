resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = "netbox_db"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.m4.large"
  manage_master_user_password = true
  username             = "admin"
  skip_final_snapshot  = true
}
