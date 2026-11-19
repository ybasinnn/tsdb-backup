output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id

  # cloud-init installs Docker on first boot, so the instance must not start
  # before the subnet has a route out.
  depends_on = [aws_route.private_nat, aws_route_table_association.private]
}

output "eice_security_group_id" {
  value = aws_security_group.eice.id
}
