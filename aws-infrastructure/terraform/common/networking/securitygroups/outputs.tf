output "alb_security_group_id" {
  value       = aws_security_group.alb_sg.id
  description = "Security Group ID for the Application Load Balancer"
}

output "ecs_tasks_security_group_id" {
  value       = aws_security_group.ecs_tasks_sg.id
  description = "Security Group ID for ECS/Fargate tasks"
}

output "alb_security_group_arn" {
  value = aws_security_group.alb_sg.arn
}

output "ecs_tasks_security_group_arn" {
  value = aws_security_group.ecs_tasks_sg.arn
}