variable "region" { type = string }
variable "profile" { type = string }
variable "shared_credentials_file" { type = string }

variable "remote_state_bucket" { type = string }

# These must match the S3 backend "key" used in each root folder
variable "sg_state_key" { type = string }
variable "ecr_state_key" { type = string }
variable "dynamodb_state_key" { type = string }

variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string }

variable "log_group_name" { type = string }

variable "common_tags" {
  type    = map(string)
  default = {}
}