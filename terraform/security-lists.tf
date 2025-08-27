#-----------------------------------------------------------------
# Security Lists (SLs) - Firewall de Perímetro da Sub-rede
#-----------------------------------------------------------------
resource "oci_core_security_list" "sl_lb_public_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SL_LB_PUBLIC_SEALS_SP"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  ingress_security_rules {
    # Permite tráfego HTTPS da Internet.
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    stateless   = false
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_security_list" "sl_oke_nodes_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SL_OKE_NODES_PRIVATE_SEALS_SP"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  ingress_security_rules {
    # Permite comunicação irrestrita a partir de outras redes da VCN.
    # O controle de acesso granular é feito pelos Network Security Groups (NSGs).
    protocol  = "all"
    source    = oci_core_vcn.vcn_seals_prod.cidr_block
    stateless = false
  }
}

resource "oci_core_security_list" "sl_oke_api_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SL_OKE_API_PRIVATE_SEALS_SP"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "all"
    source    = oci_core_vcn.vcn_seals_prod.cidr_block
    stateless = false
  }
}

resource "oci_core_security_list" "sl_db_private_seals" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn_seals_prod.id
  display_name   = "SL_DB_PRIVATE_SEALS_SP"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "all"
    source    = oci_core_vcn.vcn_seals_prod.cidr_block
    stateless = false
  }
}