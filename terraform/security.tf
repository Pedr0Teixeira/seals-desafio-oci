#-----------------------------------------------------------------
# Network Security Groups (NSGs) - Firewall de Aplicação
#-----------------------------------------------------------------
resource "oci_core_network_security_group" "nsg_lb_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NSG_LB_SEALS_PROD_SP"
}
resource "oci_core_network_security_group_security_rule" "nsg_lb_ingress_https" {
  network_security_group_id = oci_core_network_security_group.nsg_lb_seals.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false
  description               = "Permite tráfego HTTPS da Internet para o LB."
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}
resource "oci_core_network_security_group_security_rule" "nsg_lb_egress_to_oke_nodes" {
  network_security_group_id = oci_core_network_security_group.nsg_lb_seals.id
  direction                 = "EGRESS"
  protocol                  = "6" # TCP
  destination_type          = "NETWORK_SECURITY_GROUP"
  destination               = oci_core_network_security_group.nsg_oke_nodes_seals.id
  stateless                 = false
  description               = "Permite que o LB envie tráfego para os NodePorts do OKE."
  tcp_options {
    destination_port_range {
      max = 32767
      min = 30000
    }
  }
}

#----------------------------------------------------
# NSG para o Bastion Host (Acesso administrativo)
#----------------------------------------------------
resource "oci_core_network_security_group" "nsg_bastion_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NSG_BASTION_SEALS_PROD_SP"
}
resource "oci_core_network_security_group_security_rule" "nsg_bastion_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.nsg_bastion_seals.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = var.admin_source_ip
  stateless                 = false
  description               = "Permite acesso SSH apenas do IP do Jumper."
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

#----------------------------------------------------
# NSGs do Cluster OKE
#----------------------------------------------------
resource "oci_core_network_security_group" "nsg_oke_api_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NSG_OKE_API_SEALS_PROD_SP"
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_api_ingress_from_nodes" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_api_seals.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.nsg_oke_nodes_seals.id
  stateless                 = false
  description               = "Permite que os Nós conversem com a API do K8s (TCP/6443)."
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_api_egress_to_nodes" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_api_seals.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "NETWORK_SECURITY_GROUP"
  destination               = oci_core_network_security_group.nsg_oke_nodes_seals.id
  stateless                 = false
  description               = "Permite que a API do K8s converse com os Nós."
}

resource "oci_core_network_security_group" "nsg_oke_nodes_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NSG_OKE_NODES_SEALS_PROD_SP"
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_nodes_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_nodes_seals.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  stateless                 = false
  description               = "Permite que os nós acessem a internet (ex: pull de imagens)."
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_nodes_ingress_from_lb" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_nodes_seals.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.nsg_lb_seals.id
  stateless                 = false
  description               = "Permite tráfego do LB para os NodePorts."
  tcp_options {
    destination_port_range {
      max = 32767
      min = 30000
    }
  }
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_nodes_ingress_from_api" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_nodes_seals.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.nsg_oke_api_seals.id
  stateless                 = false
  description               = "Permite que a API do K8s converse com os Nós."
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_nodes_ingress_from_self" {
  network_security_group_id = oci_core_network_security_group.nsg_oke_nodes_seals.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.nsg_oke_nodes_seals.id
  stateless                 = false
  description               = "Permite a comunicação entre os nós do cluster."
}

#----------------------------------------------------
# NSG para o Banco de Dados MySQL
#----------------------------------------------------
resource "oci_core_network_security_group" "nsg_mysql_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NSG_MYSQL_SEALS_PROD_SP"
}
resource "oci_core_network_security_group_security_rule" "nsg_mysql_ingress_from_oke" {
  network_security_group_id = oci_core_network_security_group.nsg_mysql_seals.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.nsg_oke_nodes_seals.id
  stateless                 = false
  description               = "Permite que os nós do OKE acessem o banco de dados (TCP/3306)."
  tcp_options {
    destination_port_range {
      max = 3306
      min = 3306
    }
  }
}
resource "oci_core_network_security_group_security_rule" "nsg_oke_nodes_ingress_from_bastion" {
network_security_group_id = oci_core_network_security_group.nsg_oke_nodes_seals.id
direction                 = "INGRESS"
protocol                  = "6" # TCP
source_type               = "CIDR_BLOCK"
source                    = oci_core_subnet.snet_lb_public_seals.cidr_block
stateless                 = false
description               = "Permite acesso SSH do Serviço Bastion para os nós do OKE."

tcp_options {
  destination_port_range {
    max = 22
    min = 22
  }
}
}