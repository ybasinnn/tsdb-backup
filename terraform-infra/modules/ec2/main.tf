data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# The .pem only holds the private key, so derive the public key from it
# and register it with EC2.
data "tls_public_key" "this" {
  private_key_pem = file("${path.module}/${var.private_key_path}")
}

resource "aws_key_pair" "this" {
  key_name   = "${var.name}-key"
  public_key = data.tls_public_key.this.public_key_openssh
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SSH only; reach Grafana/Uptime Kuma through an SSH tunnel"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from the EC2 Instance Connect Endpoint"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.ssh_source_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  cloud_config = {
    write_files = [
      {
        path        = "/opt/grafanacompose/compose.yaml"
        content     = file("${path.module}/compose/grafana/compose.yaml")
        permissions = "0644"
      },
      {
        path        = "/opt/kumacompose/compose.yaml"
        content     = file("${path.module}/compose/kuma/compose.yaml")
        permissions = "0644"
      },
      {
        path        = "/usr/local/sbin/install-docker.sh"
        content     = file("${path.module}/scripts/install-docker.sh")
        permissions = "0755"
      },
    ]
    runcmd = [
      "/usr/local/sbin/install-docker.sh",
      "systemctl enable --now docker",
      "usermod -aG docker ubuntu",
      # Grafana runs as uid 472 inside the container and must own its data dir
      "mkdir -p /opt/grafanacompose/grafana-data /opt/kumacompose/uptimekuma-data",
      "chown -R 472:0 /opt/grafanacompose/grafana-data",
      "docker compose -f /opt/grafanacompose/compose.yaml up -d",
      "docker compose -f /opt/kumacompose/compose.yaml up -d",
    ]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  iam_instance_profile        = aws_iam_instance_profile.this.name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = false

  user_data                   = "#cloud-config\n${yamlencode(local.cloud_config)}"
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
  }

  tags = {
    Name = var.name
  }
}
