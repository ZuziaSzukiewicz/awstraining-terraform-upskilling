variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

# ALB
variable "alb_name" {
  type = string
}

variable "alb_sg" {
  type = string
}

variable "alb_subnets" {
  type = list(string)
}

# ECS Service
variable "cluster_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "task_subnets" {
  type = list(string)
}

variable "task_sg_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  type    = bool
  default = true
}

# Container
variable "container_name" {
  type = string
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type    = string
  default = "/actuator/health"
}

# Task Definition
variable "task_family" {
  type = string
}

# Fargate expects cpu/memory as strings (e.g. "256", "512", "1024")
variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "image_uri" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "common_tags" {
  type    = map(string)
  default = {}
}