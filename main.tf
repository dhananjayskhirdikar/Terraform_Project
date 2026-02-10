resource "aws_db_subnet_group" "db_subnets" {
  name       = "rds-subnet-group"
  subnet_ids = ["subnet-0482a37ccc012331b", "subnet-0ec5c308d2f01e209", "subnet-0aad31b4c64afe074", "subnet-0c64b5c0a24ba3dac", "subnet-047a1f39a17928bfd", "subnet-0b790024640f0ad48"]
  tags = {
    Name = "MyDBSubnetGroup"
  }
}
resource "aws_db_instance" "my_db" {
  allocated_storage      = 20
  db_name                = var.aws_db_instance_db_name
  engine                 = var.aws_db_instance_engine
  engine_version         = var.aws_db_instance_engine_version
  identifier             = var.aws_db_instance_identifier
  instance_class         = var.aws_db_instance_instance_class
  username               = var.aws_db_instance_username
  password               = var.aws_db_instance_password
  publicly_accessible    = false
  parameter_group_name   = var.aws_db_instance_parameter_group_name
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids = var.webserver_vpc_security_group_id
  skip_final_snapshot    = true
}
resource "aws_instance" "webserver" {
  ami                    = var.webserver_ami
  instance_type          = var.webserver_instance_type
  key_name               = var.webserver_key_name
  vpc_security_group_ids = var.webserver_vpc_security_group_id
  disable_api_termination = var.webserver_disable_api_termination
user_data = <<-EOF
              #!/bin/bash

              sudo apt update -y
              sudo apt install -y git mysql-server

              cd /opt/

              sudo git clone https://github.com/Akashbora02/Git.git
              cd /opt/Git/studentapp/

              chmod 700 docker-install.sh
              sh docker-install.sh

              cd ..
              docker compose up -d
              DB_HOST="${aws_db_instance.my_db.address}"
              DB_USER="admin"
              DB_PASS="${var.aws_db_instance_password}"

              until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" 2>/dev/null
              do
                echo "Waiting for MySQL to be ready..."
                sleep 10
              done

              sudo mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" <<SQL
              CREATE DATABASE IF NOT EXISTS studentapp;
              USE studentapp;
              CREATE TABLE IF NOT EXISTS students (
                student_id INT NOT NULL AUTO_INCREMENT,
                student_name VARCHAR(100) NOT NULL,
                student_addr VARCHAR(100) NOT NULL,
                student_age VARCHAR(3) NOT NULL,
                student_qual VARCHAR(20) NOT NULL,
                student_percent VARCHAR(10) NOT NULL,
                student_year_passed VARCHAR(10) NOT NULL,
                PRIMARY KEY (student_id)
              );
              SQL

              CONTEXT_FILE="/opt/Git/studentapp/context.xml"
              sudo sed -i "s|DB_HOST_PLACEHOLDER|$DB_HOST|g" "$CONTEXT_FILE"
              echo "User data script completed successfully!"
              echo "$DB_HOST , $DB_USER , $DB_PASS"
            EOF
}

output "webserver_publicip" {
  value = aws_instance.webserver.public_ip
}

output "my_db_arn" {
  value = aws_db_instance.my_db.address
}
