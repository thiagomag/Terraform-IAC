output "instance_public_ip" {
  description = "IP público da instância"
  value       = aws_instance.ec2_instance.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância"
  value       = aws_instance.ec2_instance.public_dns
}
