# Obtém os domínios de disponibilidade (ADs) da região.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Obtém os domínios de falha (FDs) dentro do AD principal.
data "oci_identity_fault_domains" "fds" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

#----------------------------------------------------
# OKE - Oracle Kubernetes Engine
#----------------------------------------------------
resource "oci_containerengine_cluster" "oke_cluster_seals" {
  compartment_id     = var.compartment_id
  kubernetes_version = "v1.33.1"
  name               = "OKE_CLUSTER_SEALS_SP"
  vcn_id             = oci_core_vcn.vcn_seals_prod.id

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.snet_oke_api_private_seals.id
    nsg_ids              = [oci_core_network_security_group.nsg_oke_api_seals.id]
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
    }
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }

    # Define a sub-rede pública para provisionamento de Load Balancers.
    service_lb_subnet_ids = [oci_core_subnet.snet_lb_public_seals.id]
  }
}

resource "oci_containerengine_node_pool" "oke_nodepool_seals" {
  cluster_id         = oci_containerengine_cluster.oke_cluster_seals.id
  compartment_id     = var.compartment_id
  name               = "NODEPOOL_SEALS_SP"
  kubernetes_version = oci_containerengine_cluster.oke_cluster_seals.kubernetes_version

  node_shape = "VM.Standard.E5.Flex"
  node_shape_config {
    memory_in_gbs = 16
    ocpus         = 1
  }

  node_source_details {
    image_id    = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaqqaenknmsw7achx57pur7pdqojxhmsgq24yik52tpaoaouzydmma"
    source_type = "image"
  }

  node_config_details {
    size = 3

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id           = oci_core_subnet.snet_oke_nodes_private_seals.id
      fault_domains       = data.oci_identity_fault_domains.fds.fault_domains[*].name
    }

    nsg_ids = [oci_core_network_security_group.nsg_oke_nodes_seals.id]
  }
}