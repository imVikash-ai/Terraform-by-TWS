resource "aws_s3_bucket" "remote_s3" {
  bucket = "my-bucket-for-terraform-23456"
  tags = {
    Name        = "my-bucket-for-terraform"
    Environment = "Dev"
  }
}