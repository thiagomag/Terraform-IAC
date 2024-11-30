# Definir o provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Instância EC2
resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name # Nome do par de chaves existente na AWS

  # Associa o grupo de segurança existente
  vpc_security_group_ids = ["sg-049adffa8ce524981"]

  # Comandos de inicialização (User Data)
  user_data = <<-EOF
    #!/bin/bash

    # Atualizar pacotes
    sudo yum update -y

    # Instalar Docker
    sudo amazon-linux-extras enable docker
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -aG docker ec2-user

    # Instalar Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Instalar Nginx
    sudo amazon-linux-extras enable nginx1
    sudo yum install -y nginx

    # Configurar Nginx como Proxy Reverso
    sudo bash -c 'cat > /etc/nginx/conf.d/reverse-proxy.conf << EOL
    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://127.0.0.1:8080; # Frontend Vue.js
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection keep-alive;
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }

        location /api/service1/ {
            proxy_pass http://127.0.0.1:8081; # Backend Service 1
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection keep-alive;
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }

        location /api/service2/ {
            proxy_pass http://127.0.0.1:8082; # Backend Service 2
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection keep-alive;
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }
    }
    EOL'

    # Reiniciar Nginx
    sudo systemctl enable nginx
    sudo systemctl restart nginx
  EOF

  tags = {
    Name = "Terraform-EC2"
  }
}
