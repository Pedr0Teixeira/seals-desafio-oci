resource "oci_mysql_mysql_db_system" "mysql_db_seals" {
  admin_password      = var.db_password
  admin_username      = "admin"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape_name          = "MySQL.2"
  subnet_id           = oci_core_subnet.snet_db_private_seals.id
  display_name        = "MYSQL_DB_SEALS_SP"

  maintenance {
    # Formato: "{dia-da-semana} {HH:mm}"
    window_start_time = "Sun 04:00"
  }

  backup_policy {
    is_enabled        = true
    retention_in_days = 7
    window_start_time = "02:00"
    pitr_policy {
      is_enabled = true
    }
  }
}