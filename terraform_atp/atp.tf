


resource "oci_database_autonomous_database" "my_autonomous_database" {
    #Required
    admin_password = var.autonomous_database_admin_password
    compartment_id = var.compartment_ocid
    cpu_core_count = var.autonomous_database_cpu_core_count
    data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
    db_name = var.autonomous_database_db_name

    #Optional
    display_name = var.autonomous_database_display_name
    license_model = var.autonomous_database_license_model
}
