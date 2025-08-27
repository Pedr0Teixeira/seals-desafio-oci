variable "tenancy_ocid" {
  description = "OCID da sua Tenancy."
}
variable "user_ocid" {
  description = "OCID do seu usuário."
}
variable "fingerprint" {
  description = "Fingerprint da chave da API."
}
variable "private_key_path" {
  description = "Caminho para a sua chave privada da API."
}
variable "region" {
  description = "Região OCI primária."
}
variable "compartment_id" {
  description = "OCID do compartimento de destino."
}
variable "db_password" {
  description = "Senha para o usuário admin do banco de dados MySQL."
  sensitive   = true
}
variable "admin_source_ip" {
  description = "O endereço IP ou CIDR do administrador para permitir acesso SSH ao Bastion."
}