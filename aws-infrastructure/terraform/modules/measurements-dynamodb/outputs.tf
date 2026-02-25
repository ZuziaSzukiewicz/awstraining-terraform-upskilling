output "table_name" {
  value = aws_dynamodb_table.measurements_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.measurements_table.arn
}