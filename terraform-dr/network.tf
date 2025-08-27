#----------------------------------------------------
# VCN
#----------------------------------------------------
resource "oci_core_vcn" "vcn_seals_prod" {
  compartment_id = var.compartment_id
  display_name   = "VCN_SEALS_PROD_VH"
  cidr_block     = "10.1.0.0/16" # <-- CIDR CORRIGIDO
  dns_label      = "vcnsealsvh"
}

#----------------------------------------------------
# Gateways
#----------------------------------------------------
resource "oci_core_internet_gateway" "igw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "IGW_SEALS_PROD_VH"
  enabled        = true
}

resource "oci_core_nat_gateway" "ngw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NGW_SEALS_PROD_VH"
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = [local.oci_services_network_names[var.region]]
    regex  = false
  }
}

resource "oci_core_service_gateway" "sgw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SGW_SEALS_PROD_VH"
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

#-----------------------------------------------------------------
# Route Tables Dedicadas
#-----------------------------------------------------------------
resource "oci_core_route_table" "rt_lb_public_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "RT_LB_PUBLIC_SEALS_VH"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw_seals_prod.id
  }
}

resource "oci_core_route_table" "rt_oke_nodes_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "RT_OKE_NODES_PRIVATE_SEALS_VH"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw_seals_prod.id
  }
  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    network_entity_id = oci_core_service_gateway.sgw_seals_prod.id
  }
}

resource "oci_core_route_table" "rt_oke_api_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "RT_OKE_API_PRIVATE_SEALS_VH"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw_seals_prod.id
  }
  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    network_entity_id = oci_core_service_gateway.sgw_seals_prod.id
  }
}

resource "oci_core_route_table" "rt_db_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "RT_DB_PRIVATE_SEALS_VH"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.ngw_seals_prod.id
  }
  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    network_entity_id = oci_core_service_gateway.sgw_seals_prod.id
  }
  # NOVA REGRA DE ROTA PARA O DRG
  route_rules {
    destination       = "10.0.0.0/16" # CIDR da VCN Primária (São Paulo)
    network_entity_id = oci_core_drg.drg_vh.id
    description       = "Rota para a VCN Primária via Peering"
  }
}

#-----------------------------------------------------------------
# Subnets
#-----------------------------------------------------------------
resource "oci_core_subnet" "snet_lb_public_seals" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn_seals_prod.id
  display_name      = "SNET_LB_PUBLIC_SEALS_VH"
  cidr_block        = "10.1.1.0/24"
  dns_label         = "publbvh"
  route_table_id    = oci_core_route_table.rt_lb_public_seals.id
  security_list_ids = [oci_core_security_list.sl_lb_public_seals.id]
}

resource "oci_core_subnet" "snet_oke_nodes_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_OKE_NODES_PRIVATE_SEALS_VH"
  cidr_block                 = "10.1.10.0/24"
  dns_label                  = "okenodesvh"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_oke_nodes_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_oke_nodes_private_seals.id]
}

resource "oci_core_subnet" "snet_oke_api_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_OKE_API_PRIVATE_SEALS_VH"
  cidr_block                 = "10.1.5.0/24"
  dns_label                  = "okeapivh"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_oke_api_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_oke_api_private_seals.id]
}

resource "oci_core_subnet" "snet_db_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_DB_PRIVATE_SEALS_VH"
  cidr_block                 = "10.1.20.0/24"
  dns_label                  = "dbvh"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_db_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_db_private_seals.id]
}

# --- DRG E ATTACHMENT PARA DR (VINHEDO) ---
resource "oci_core_drg" "drg_vh" {
  compartment_id = var.compartment_id
  display_name   = "DRG_SEALS_PROD_VH"
}

resource "oci_core_drg_attachment" "drg_attachment_vh" {
  drg_id = oci_core_drg.drg_vh.id
  vcn_id = oci_core_vcn.vcn_seals_prod.id
}