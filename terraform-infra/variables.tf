variable "s3_region" {
  description = "AWS region for the backup bucket"
  type        = string
  default     = "eu-west-1"
}

variable "ec2_region" {
  description = "AWS region for the EC2 instance"
  type        = string
  default     = "eu-west-1"
}