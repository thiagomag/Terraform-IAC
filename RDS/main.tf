terraform {
  cloud {

    organization = "Thiago"

    workspaces {
      name = "aws-thiago"
    }
  }
}

# Grupo de Segurança para RDS
resource "aws_security_group" "rds_security_group" {
  name        = "rds_security_group"
  description = "Permitir acesso ao RDS"

  ingress {
    description = "Permitir acesso ao PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "rds_instance" {
  identifier          = var.rds_instance_name
  engine              = "postgres"
  instance_class      = "db.t3.micro" # Free Tier elegível
  allocated_storage   = var.rds_allocated_storage
  username            = var.rds_username
  password            = var.rds_password
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  skip_final_snapshot = true
  publicly_accessible = true

  tags = {
    Name = "Terraform-RDS"
  }
}

# Instalar o PostgreSQL CLI (psql)
resource "null_resource" "install_psql" {
  provisioner "local-exec" {
    command = <<EOT
      # Verificar se o psql já está instalado
      if ! command -v psql &> /dev/null; then
        # Identificar o sistema operacional e instalar o psql
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
          sudo apt update && sudo apt install -y postgresql-client
        elif [[ "$OSTYPE" == "darwin"* ]]; then
          brew install libpq && brew link --force libpq
        elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "win32" ]]; then
          choco install postgresql
        fi
      fi
    EOT
  }
}

# Script de Inicialização para criar múltiplos bancos de dados
resource "null_resource" "initialize_databases" {
  depends_on = [aws_db_instance.rds_instance]

  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=${var.rds_password} psql -h ${aws_db_instance.rds_instance.address} -U ${var.rds_username} -d postgres -c "CREATE DATABASE meu_site;"
    EOT
  }
}
