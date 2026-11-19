data "aws_region" "current" {}

locals {
  private_key = abspath("${path.module}/${var.private_key_path}")

  # The instance has no public IP; SSH goes through the EC2 Instance Connect Endpoint.
  proxy_command = "aws ec2-instance-connect open-tunnel --instance-id ${aws_instance.this.id} --region ${data.aws_region.current.region}"
}

output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "ssh_command" {
  value = "ssh -i ${local.private_key} -o ProxyCommand='${local.proxy_command}' ubuntu@${aws_instance.this.id}"
}

output "ansible_inventory" {
  description = "Paste into an inventory.ini"
  value       = "[poc]\n${aws_instance.this.id} ansible_user=ubuntu ansible_ssh_private_key_file=${local.private_key} ansible_ssh_common_args='-o ProxyCommand=\"${local.proxy_command}\"'"
}
