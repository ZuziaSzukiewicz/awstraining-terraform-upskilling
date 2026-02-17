provider "aws" {
  region                  = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile                 = var.profile
}

module "remote_state_bucket" {
  source = "../../../modules/bucket"
  name = var.remote_state_bucket
}


