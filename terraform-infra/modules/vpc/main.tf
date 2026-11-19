data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  az = data.aws_availability_zones.available.names[0]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
  }
}

# Public side: only exists so the NAT gateway can reach the internet.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = local.az

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-nat"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

# Private side: the instance gets no public IP. Outbound traffic (apt, Docker
# images) goes through the NAT gateway.
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = local.az

  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Backup uploads to S3 skip the NAT gateway (and its per-GB charge).
# Only covers buckets in this VPC's region.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.name}-s3"
  }
}

# EC2 Instance Connect Endpoint: SSH into the private instance without a
# bastion or public IP. Access is controlled by IAM (ec2-instance-connect:OpenTunnel).
resource "aws_security_group" "eice" {
  name        = "${var.name}-eice-sg"
  description = "EC2 Instance Connect Endpoint; SSH out to the VPC"
  vpc_id      = aws_vpc.this.id

  egress {
    description = "SSH to instances in the VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = aws_subnet.private.id
  security_group_ids = [aws_security_group.eice.id]

  # The instance sees the endpoint's IP, so its SG can allow the endpoint SG.
  preserve_client_ip = false

  tags = {
    Name = "${var.name}-eice"
  }
}
