provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

module "ecs-backend-cluster" {
  source       = "../../../modules/ecs-backend-cluster"
  name = "awsupskilling_ecs_cluster"
}