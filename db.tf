

resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = ["subnet-xxxxxxxxxxxx", "subnet-yyyyyyyyyyy"]

  tags = {
    Name = "My RDS subnet group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound access to RDS"
  vpc_id      = "vpc-xxxxxxxx"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IPs for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS security group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "my-postgres-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = "postgresadmin"
  password                = "xxxxxxxxxxxxx" # Use secrets management in production
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  multi_az                = false
  storage_encrypted       = false
  backup_retention_period = 0

  tags = {
    Name = "PostgreSQL DB"
  }
}
