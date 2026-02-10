variable "webserver_ami" {
  default = "ami-0ecb62995f68bb549"
}
variable "webserver_instance_type" {
  default = "t3.micro"
}
variable "webserver_key_name" {
  default = "30july"
}
variable "webserver_vpc_security_group_id" {
  default = "sg-0bbfe8e7d4bf3c179"
}
#variable "webserver_count" {
#  default = 5
#}
variable "webserver_disable_api_termination" {
  default = false
}

variable "aws_db_instance_db_name" {
  default = "studentapp"
}
variable "aws_db_instance_engine" {
  default = "mysql"
}
variable "aws_db_instance_engine_version" {
  default = "8.0"
}
variable "aws_db_instance_identifier" {
  default = "studentapp"
}
variable "aws_db_instance_instance_class" {
  default = "db.t4g.micro"
}
variable "aws_db_instance_username" {
  default = "admin"
}
variable "aws_db_instance_password" {
  default = "12345678"
}
variable "aws_db_instance_parameter_group_name" {
  default = "default.mysql8.0"
}
