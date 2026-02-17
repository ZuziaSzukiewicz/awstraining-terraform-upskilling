resource "aws_s3_bucket" "simple_bucket" {
  bucket = var.name
}