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

data "aws_iam_role" "exec"{
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "task"{
  name = "ecs-taskdef"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.vpc_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "securitygroups" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.securitygroups_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "globals" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.globals_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

module "ecs-backend-service" {
  source = "../../../modules/ecs-backend-service"

  region = var.region
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  alb_name    = "awsupskilling-alb"
  alb_sg      = data.terraform_remote_state.securitygroups.outputs.alb_security_group_id
  alb_subnets = data.terraform_remote_state.vpc.outputs.public_subnets_id

  cluster_id    = data.terraform_remote_state.globals.outputs.ecs_cluster_name
  service_name  = "awsupskilling_service"
  desired_count = 2

  task_subnets     = data.terraform_remote_state.vpc.outputs.public_subnets_id
  task_sg_ids      = [data.terraform_remote_state.securitygroups.outputs.ecs_tasks_security_group_id]
  assign_public_ip = true

  container_name    = "my-app"
  container_port    = 8081
  health_check_path = "/actuator/health"

  task_family        = "my-app-task"
  cpu                = "256"
  memory             = "512"

  execution_role_arn = data.aws_iam_role.exec.arn
  task_role_arn      = data.aws_iam_role.task.arn

  image_uri = "${data.terraform_remote_state.globals.outputs.ecr_repository_url}:latest"

  environment = [
    {
      name  = "DYNAMODB_TABLE"
      value = data.terraform_remote_state.globals.outputs.dynamodb_table_name
    },
    {
      name  = "HUB"
      value = "EMEA"
    },
    {
      name  = "STAGE"
      value = "TEST"
    }
  ]

  secrets = [
    {
      name = "SPRING_APPLICATION_JSON"
      valueForm = "arn:aws:secretsmanager:eu-central-1:497196579670:secret:awsupskilling-secret-authorization-Daln1m"
    }
      
  ]
}