provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

module "ecr" {
  source             = "../../../modules/ecr"
  name = "awsupskilling_ecr_repo"
  image_tag_mutability = "MUTABLE"
}
