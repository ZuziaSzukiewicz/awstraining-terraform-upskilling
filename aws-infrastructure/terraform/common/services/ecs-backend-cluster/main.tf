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

module "ecs-backend-cluster" {
  source       = "../../../modules/ecs-backend-cluster"
  name = "awsupskilling_ecs_cluster"
}