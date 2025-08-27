resource "oci_bastion_bastion" "bastion_seals_service" {
  bastion_type = "standard"

  compartment_id = var.compartment_id

  target_subnet_id = oci_core_subnet.snet_lb_public_seals.id

  client_cidr_block_allow_list = [
    var.admin_source_ip,
    "177.37.133.128/32" # IP da minha casa
  ]

  name = "BASTION_SEALS_SERVICE_SP"

  max_session_ttl_in_seconds = 10800
}