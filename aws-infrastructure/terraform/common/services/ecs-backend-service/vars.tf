variable "region" {
  description = "Region to launch configuration in"
}
variable "remote_state_bucket" {
  description = "Remote state bucket for saving state"
}
variable "profile" {
  description = "Default profile id"
}
variable "shared_credentials_file" {
  description = "Path to cloud credentials"
}

variable "environment" {
  description = "Path to cloud credentials"
}

variable "securitygroups_state_key" { 
  type = string
  default = "securitygroups.tfstate" 
   }

variable "vpc_state_key" { 
  type = string
  default = "vpc.tfstate" 
   }

variable "globals_state_key" { 
  type = string
  default = "globals.tfstate" 
   }
variable "execution_role_arn" { 
  type = string
   }
variable "task_role_arn" { 
  type = string
  default = null 
  }

variable "log_group_name" { 
  type = string
  default = null 
   }

variable "common_tags" {
  type    = map(string)
  default = {}
}