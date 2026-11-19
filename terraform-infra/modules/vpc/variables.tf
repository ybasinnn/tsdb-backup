variable "name" {
  description = "Name prefix for created resources"
  type        = string
  default     = "ansible-poc"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet; only holds the NAT gateway"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet the EC2 instance is launched in"
  type        = string
  default     = "10.0.1.0/24"
}
