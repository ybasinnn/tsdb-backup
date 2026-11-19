resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name    = var.bucket_name
    Purpose = "tsdb-backups"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Backups should be uploaded straight to DEEP_ARCHIVE
# (e.g. `aws s3 cp x.tar.gz s3://.../backups/ --storage-class DEEP_ARCHIVE`).
# This rule is a safety net that moves anything uploaded as STANDARD into
# DEEP_ARCHIVE at the next lifecycle run.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "deep-archive-backups"
    status = "Enabled"

    filter {
      prefix = var.backup_prefix
    }

    transition {
      days          = 0
      storage_class = "DEEP_ARCHIVE"
    }
    
    expiration {
      days = 180
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Only accept TLS connections.
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*",
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}
