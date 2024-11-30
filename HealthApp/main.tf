# Definir o provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Usar um par de chaves existente
data "aws_key_pair" "existing_key" {
  key_name = "ThiagoDev"  # Substitua pelo nome da chave existente
}

# Script User Data para instalar Docker
data "template_file" "user_data" {
  template = <<-EOF
    #!/bin/bash
    # Atualizar o sistema
    apt-get update -y
    # Instalar pacotes necessários
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    # Adicionar a chave GPG do Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # Adicionar o repositório Docker
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    # Atualizar novamente após adicionar o repositório Docker
    apt-get update -y
    # Instalar Docker
    apt-get install -y docker-ce
    # Iniciar e habilitar o serviço Docker
    systemctl start docker
    systemctl enable docker
  EOF
}

# Usar um grupo de segurança existente
data "aws_security_group" "existing_sg" {
  # Buscando pelo nome do grupo de segurança existente
  #filter {
  #  name   = "group-name"
  #  values = ["meu-grupo-de-seguranca"]
  #}

  # Opcional: Se preferir, você pode buscar o SG diretamente pelo ID
  id = "sg-073de0b992fa5b677"
}

# Criar uma instância EC2
resource "aws_instance" "my_instance" {
  ami           = "ami-0e86e20dae9224db8"  # AMI Ubuntu na região us-east-1
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.existing_key.key_name
  vpc_security_group_ids = [data.aws_security_group.existing_sg.id]  # Referência ao grupo de segurança existente

  # Configurando o volume root
  root_block_device {
    volume_type = "gp3"   # Tipo de volume (gp3, gp2, io1, io2, etc.)
    volume_size = 30      # Tamanho em GB do disco raiz
    delete_on_termination = true  # Excluir o volume quando a instância for encerrada
  }

  # Incluir o User Data script para instalar Docker
  user_data = data.template_file.user_data.rendered

  # Tags para a instância
  tags = {
    Name = "HealthApp"
  }
}

# Saída do IP da instância criada
output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}
