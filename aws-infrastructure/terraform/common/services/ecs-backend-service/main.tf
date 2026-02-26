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

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.vpc_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.cluster_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
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

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    key            = var.iam_state_key
    region         = var.region
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

module "ecs-backend-service" {
  source = "../../../modules/ecs-backend-service"

  region = var.region
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  alb_name    = "awsupskilling-alb"
  alb_sg      = data.terraform_remote_state.sg.outputs.alb_security_group_id
  alb_subnets = data.terraform_remote_state.vpc.outputs.public_subnets_id

  cluster_id    = data.terraform_remote_state.cluster.outputs.ecs_cluster_id
  service_name  = "moja-aplikacja-service"
  desired_count = 2

  task_subnets     = data.terraform_remote_state.vpc.outputs.public_subnets_id
  task_sg_ids      = [data.terraform_remote_state.sg.outputs.ecs_tasks_security_group_id]
  assign_public_ip = true

  container_name    = "moja-aplikacja"
  container_port    = 8081
  health_check_path = "/actuator/health"

  task_family        = "moja-aplikacja-task"
  cpu                = "256"
  memory             = "512"

  execution_role_arn = data.terraform_remote_state.iam.outputs.execution_role_arn
  task_role_arn      = data.terraform_remote_state.iam.outputs.task_role_arn

  image_uri = "${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:latest"
  log_group_name = var.log_group_name

  environment = [
    {
      name  = "DYNAMODB_TABLE"
      value = data.terraform_remote_state.dynamodb.outputs.dynamodb_table_name
    }
  ]

  common_tags = var.common_tags
}