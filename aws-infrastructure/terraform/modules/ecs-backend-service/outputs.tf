output "alb_arn" {
  value = aws_lb.aws_upskilling_alb.arn
}

output "alb_dns" {
  value = aws_lb.aws_upskilling_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.awsupskilling_target_group.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.awsupskilling_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.awsupskilling_taskdef.arn
}