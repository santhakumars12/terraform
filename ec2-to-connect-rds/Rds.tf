resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]  #if multi AZ add another subnet
}

resource "aws_security_group" "sg_for_rds" {
  name        = "my-db-sg"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 3306  # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_for_ec2.id]
  }
}

resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "dbdatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

    # Attach the DB security group
  vpc_security_group_ids = [aws_security_group.sg_for_rds.id]  
    tags = {
        Name = "ec2_to_mysql_rds"
    }
}

resource "aws_security_group_rule" "ec2instance_to_db" {
  type        = "ingress"
  from_port   = 3306  # MySQL port
  to_port     = 3307
  protocol    = "tcp"
  security_group_id = aws_security_group.sg_for_rds.id  # RDS security group
  source_security_group_id = aws_security_group.sg_for_ec2.id # EC2 security group
}
