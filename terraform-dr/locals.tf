locals {
  # Mapa dos nomes da Oracle Services Network por região
  oci_services_network_names = {
    "sa-saopaulo-1" = "All GRU Services In Oracle Services Network"
    "sa-vinhedo-1"  = "All VCP Services In Oracle Services Network"
    # Adicione outras regiões aqui se necessário no futuro
  }
}
