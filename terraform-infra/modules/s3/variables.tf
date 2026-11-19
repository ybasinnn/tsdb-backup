variable "bucket_name" {
  description = "Name of the TSDB backup bucket"
  type        = string
  default     = "tsdb-backup-da"
}

variable "backup_prefix" {
  description = "Key prefix the tar.gz backups are uploaded under"
  type        = string
  default     = "backups/"
}
