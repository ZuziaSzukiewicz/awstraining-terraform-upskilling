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

module "aws_dynamodb_table" {
  source             = "../../../modules/measurements-dynamodb"
  name = "Measurements"
  hash_key = "deviceId"
  range_key = "creationTime"
}
