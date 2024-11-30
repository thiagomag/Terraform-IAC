variable "rds_instance_name" {
  default = "banco-de-dados"
}

variable "rds_username" {
  default = "thiago" # Substitua pelo seu nome de usuário
}

variable "rds_password" {
  default = "" # Substitua por uma senha segura
}

variable "rds_allocated_storage" {
  default = 100 # Armazenamento em GB
}

variable "allowed_ips" {
  description = "Lista de IPs permitidos para acessar o RDS"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Substitua pelo seu IP público para maior segurança
}
