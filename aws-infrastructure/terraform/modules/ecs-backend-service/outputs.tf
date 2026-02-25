output "alb_arn" {
  value = aws_lb.aws_upskilling_alb.arn
}

output "alb_dns" {
  value = aws_lb.aws_upskilling_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.awsupskilling_target_group.arn
}