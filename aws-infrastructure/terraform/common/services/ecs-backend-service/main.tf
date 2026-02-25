provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = var.profile
}

terraform {
  backend "s3" {
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "globals" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "globals.tfstate"
    region = var.region
  }
}

# Local VPC module (this root creates VPC)
module "vpc" {
  source = "../../../modules/vpc"
}

# Remote state: Security Groups (created in another folder/state)
data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.sg_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

# Remote state: ECR
data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.ecr_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

# Remote state: DynamoDB
data "terraform_remote_state" "dynamodb" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.dynamodb_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

# ECS Cluster
module "ecs_cluster" {
  source = "../../../modules/ecs-backend-cluster"
  name   = "awsupskilling_ecs_cluster"
}

# Backend service (ALB+TG+Listener+TaskDef+Service)
module "backend_service" {
  source = "../../../modules/ecs-backend-service"

  region = var.region
  vpc_id = module.vpc.vpc_id

  alb_name    = "awsupskilling-alb"
  alb_sg      = data.terraform_remote_state.sg.outputs.alb_security_group_id
  alb_subnets = module.vpc.public_subnets_id

  cluster_id    = module.ecs_cluster.cluster_id
  service_name  = "moja-aplikacja-service"
  desired_count = 2

  task_subnets     = module.vpc.public_subnets_id
  task_sg_ids      = [data.terraform_remote_state.sg.outputs.ecs_tasks_security_group_id]
  assign_public_ip = true

  container_name    = "moja-aplikacja"
  container_port    = 8081
  health_check_path = "/actuator/health"

  task_family        = "moja-aplikacja-task"
  cpu                = "256"
  memory             = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  image_uri      = "${data.terraform_remote_state.ecr.outputs.repository_url}:latest"
  log_group_name = var.log_group_name

  environment = [
    {
      name  = "DYNAMODB_TABLE"
      value = data.terraform_remote_state.dynamodb.outputs.table_name
    }
  ]

  common_tags = var.common_tags
}