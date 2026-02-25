provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

module "aws_dynamodb_table" {
  source             = "../../../modules/measurements-dynamodb"
  name = "Measurements"
  hash_key = "deviceId"
  range_key = "creationTime"
}
