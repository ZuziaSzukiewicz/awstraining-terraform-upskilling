provider "aws" {
  region  = var.region
  profile = var.profile
}

module "bucket" {
  source = "../../../modules/simple-bucket"
  name   = "<<UNIQUE_BUCKET_NAME>>"
}

