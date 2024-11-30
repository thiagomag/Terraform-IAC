output "rds_endpoint" {
  description = "Endpoint do RDS"
  value       = aws_db_instance.rds_instance.address
}

output "rds_port" {
  description = "Porta do RDS"
  value       = aws_db_instance.rds_instance.port
}
