resource "aws_iam_role" "this" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "backup_bucket" {
  name = "${var.name}-backup-bucket"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::${var.backup_bucket}"
      },
      {
        Sid      = "AllowBackupUploads"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:AbortMultipartUpload"]
        Resource = "arn:aws:s3:::${var.backup_bucket}/backups/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.this.name
}
