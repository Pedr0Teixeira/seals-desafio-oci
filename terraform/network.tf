#----------------------------------------------------
# VCN
#----------------------------------------------------
resource "oci_core_vcn" "vcn_seals_prod" {
  compartment_id = var.compartment_id
  display_name   = "VCN_SEALS_PROD_SP"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "vcnsealssp"
}

#----------------------------------------------------
# Gateways
#----------------------------------------------------
resource "oci_core_internet_gateway" "igw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "IGW_SEALS_PROD_SP"
  enabled        = true
}

resource "oci_core_nat_gateway" "ngw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "NGW_SEALS_PROD_SP"
}

data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All GRU Services In Oracle Services Network"]
    regex  = false
  }
}

resource "oci_core_service_gateway" "sgw_seals_prod" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SGW_SEALS_PROD_SP"
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
  display_name   = "RT_LB_PUBLIC_SEALS_SP"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw_seals_prod.id
  }
}

resource "oci_core_route_table" "rt_oke_nodes_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "RT_OKE_NODES_PRIVATE_SEALS_SP"
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
  display_name   = "RT_OKE_API_PRIVATE_SEALS_SP"
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
  display_name   = "RT_DB_PRIVATE_SEALS_SP"
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

#-----------------------------------------------------------------
# Subnets
#-----------------------------------------------------------------
resource "oci_core_subnet" "snet_lb_public_seals" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn_seals_prod.id
  display_name      = "SNET_LB_PUBLIC_SEALS_SP"
  cidr_block        = "10.0.1.0/24"
  dns_label         = "publb"
  route_table_id    = oci_core_route_table.rt_lb_public_seals.id
  security_list_ids = [oci_core_security_list.sl_lb_public_seals.id]
}

resource "oci_core_subnet" "snet_oke_nodes_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_OKE_NODES_PRIVATE_SEALS_SP"
  cidr_block                 = "10.0.10.0/24"
  dns_label                  = "okenodes"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_oke_nodes_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_oke_nodes_private_seals.id]
}

resource "oci_core_subnet" "snet_oke_api_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_OKE_API_PRIVATE_SEALS_SP"
  cidr_block                 = "10.0.5.0/24"
  dns_label                  = "okeapi"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_oke_api_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_oke_api_private_seals.id]
}

resource "oci_core_subnet" "snet_db_private_seals" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn_seals_prod.id
  display_name               = "SNET_DB_PRIVATE_SEALS_SP"
  cidr_block                 = "10.0.20.0/24"
  dns_label                  = "db"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.rt_db_private_seals.id
  security_list_ids          = [oci_core_security_list.sl_db_private_seals.id]
}