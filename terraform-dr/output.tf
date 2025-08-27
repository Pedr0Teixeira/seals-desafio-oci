# Exibe o OCID do serviço OCI Bastion para referência.
output "bastion_service_id" {
  description = "O OCID do serviço OCI Bastion."
  value       = oci_bastion_bastion.bastion_seals_service.id
}

# Exibe o IP privado do endpoint do Bastion dentro da sua VCN.
output "bastion_private_endpoint_ip" {
  description = "O endereço IP privado do endpoint do serviço OCI Bastion."
  value       = oci_bastion_bastion.bastion_seals_service.private_endpoint_ip_address
}

# Exibe o OCID do cluster OKE, útil para configurar o kubectl.
output "oke_cluster_id" {
  description = "OCID do cluster OKE."
  value       = oci_containerengine_cluster.oke_cluster_seals.id
}

# Exibe o endereço IP privado do banco de dados MySQL para a aplicação.
output "mysql_db_private_ip" {
  description = "Endereço IP privado do endpoint do MySQL DB System."
  value       = oci_mysql_mysql_db_system.mysql_db_seals.endpoints[0].ip_address
}

# Exibe o OCID da VCN principal.
output "vcn_id" {
  description = "OCID da VCN principal."
  value       = oci_core_vcn.vcn_seals_prod.id
}