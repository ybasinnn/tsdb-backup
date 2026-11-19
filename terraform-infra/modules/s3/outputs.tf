output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "upload_example" {
  description = "Upload a backup directly into Deep Archive"
  value       = "aws s3 cp <backup>.tar.gz s3://${aws_s3_bucket.this.id}/${var.backup_prefix} --storage-class DEEP_ARCHIVE"
}
