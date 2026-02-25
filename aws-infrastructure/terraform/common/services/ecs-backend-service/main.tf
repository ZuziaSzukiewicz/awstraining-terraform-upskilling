// TODO: implement
// here we will place lb, tg, listener including task definition for backend service (it is logically connected)
//task def
//service

provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

module "vpc" {
  source = "../../../modules/vpc"
}

module "ecs_cluster" {
  source = "../../../modules/ecs-backend-cluster"
  cluster_name = "awsupskilling_ecs_cluster"
}

//NIE MA TEGO JESZCZE W MODULE
module "ecs_task" {
  source = "../../../modules/ecs-backend-service"
  task_name          = "moja-aplikacja-task"
  container_name     = "moja-aplikacja"
  container_image    = "497196579670.dkr.ecr.eu-central-1.amazonaws.com/awsupskilling_ecr_repo:latest"
  container_port     = 8081
  memory             = 512
  cpu                = 256
}

module "ecs_cluster" {
  source = "../../../modules/ecs-backend-cluster"
  cluster_name = "awsupskilling_ecs_cluster"
}

module "alb" {
  source = "../../../modules/ecs-backend-service"
  alb_name   = "aws_upskilling_alb_tg"
  vpc_id     = module.vpc.vpc_id
  subnets    = module.vpc.public_subnets
  alb_sg     = module.vpc.sg_ids[0]
  target_sg  = module.security_groups.sg_ids[1]
  tg_port    = 8081
}

module "ecs_service" {
  source               = "./modules/ecs-service"
  service_name         = "moja-aplikacja-service"
  cluster_id           = module.ecs_cluster.cluster_id
  task_definition_arn  = module.ecs_task.task_definition_arn
  subnets              = module.network.public_subnets
  sg_ids               = [module.network.sg_ids[1]]   # security group do tasków
  target_group_arn     = module.alb.target_group_arn
  container_name       = "moja-aplikacja"
  container_port       = 8081
}