variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "ThiagoMagdalenaDev"
  description = "Nome do par de chaves SSH existente na AWS"
}


variable "ami_id" {
  default = "ami-0866a3c8686eaeeba" # Ubuntu 24.04 LTS
}

variable "allowed_ips" {
  description = "IPs permitidos para acessar a instância"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Substitua pelo seu IP público para maior segurança
}
