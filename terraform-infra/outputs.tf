output "bucket_name" {
  value = module.s3.bucket_name
}

output "upload_example" {
  value = module.s3.upload_example
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "private_ip" {
  value = module.ec2.private_ip
}

output "ssh_command" {
  value = module.ec2.ssh_command
}

output "ansible_inventory" {
  value = module.ec2.ansible_inventory
}
