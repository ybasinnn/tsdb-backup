variable "name" {
  description = "Name prefix for created resources"
  type        = string
  default     = "ansible-poc"
}

variable "instance_type" {
  description = "t3.micro = 2 vCPU / 1 GiB RAM"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root SSD (gp3) size in GiB"
  type        = number
  default     = 20
}

variable "private_key_path" {
  description = "Path to the existing .pem private key; its public half is uploaded as an EC2 key pair"
  type        = string
  default     = "mon_backup.pem"
}

variable "vpc_id" {
  description = "VPC the instance security group is created in"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet the instance is launched in"
  type        = string
}

variable "ssh_source_security_group_id" {
  description = "Security group allowed to reach SSH (the EC2 Instance Connect Endpoint)"
  type        = string
}

variable "backup_bucket" {
  description = "S3 bucket the instance can list, and read/write objects under backups/ in"
  type        = string
  default     = "tsdb-backup-da"
}
