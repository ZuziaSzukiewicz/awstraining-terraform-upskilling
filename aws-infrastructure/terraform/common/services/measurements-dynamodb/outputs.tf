output "dynamodb_table_name" {
  value = module.aws_dynamodb_table.table_name
}

output "dynamodb_table_arn" {
  value = module.aws_dynamodb_table.table_arn
}
