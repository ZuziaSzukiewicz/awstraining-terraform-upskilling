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

resource "aws_iam_role" "ecs_execution" {
  name               = "awsupskilling-ecs-execution-role"
  assume_role_policy = file("${path.module}/ecs-assume-role.json")
  tags               = var.common_tags
}

resource "aws_iam_role" "ecs_task" {
  name               = "awsupskilling-ecs-task-role"
  assume_role_policy = file("${path.module}/ecs-assume-role.json")
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}