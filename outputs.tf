output "bastion_host_public_ip" {
  value = aws_instance.bastion.public_ip
}