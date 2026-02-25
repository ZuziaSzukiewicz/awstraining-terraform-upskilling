# Base setting for the modules like which credentials are to be used etc.
provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

terraform {
  backend "s3" {
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "vpc.tfstate"
    region = var.region
  }
}

resource "aws_security_group" "alb_sg" {
  name = "awsupskilling-alb-sg"
  description = "ALB Securitu group"
  vpc_id = "vpc-09ff9a9f4fa826e31"
}

resource "aws_security_group" "ecs_tasks_sg" {
  name = "awsupskilling-ecs-tasks-sg"
  description = "ECS Security group"
  vpc_id = "vpc-09ff9a9f4fa826e31"
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
    security_group_id = aws_security_group.alb_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs_8081"{
    security_group_id = aws_security_group.alb_sg.id
    referenced_security_group_id = aws_security_group.ecs_tasks_sg.id
    from_port        = 8081
    to_port          = 8081
    ip_protocol         = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb_8081"{
    security_group_id = aws_security_group.ecs_tasks_sg.id
    referenced_security_group_id = aws_security_group.alb_sg.id
    from_port = 8081
    to_port = 8081
    ip_protocol = "tcp"
}