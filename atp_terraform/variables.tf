# OCI Service
variable "tenancy_ocid" {}

variable "compartment_ocid" {}

variable "fingerprint" {}

variable "private_key_path" {}

variable "user_ocid" {}

variable "region" {
  default = "eu-frankfurt-1"
}



variable "autonomous_database_admin_password" {
  default = "MyPassword123456"
}

variable "autonomous_database_cpu_core_count" {
  default = "1"
}

variable "autonomous_database_data_storage_size_in_tbs" {
  default = "1"
}

variable "autonomous_database_db_name" {
  default = "ATPDB1"
}

variable "autonomous_database_display_name" {
  default = "ATP_DB_1"
}

variable "autonomous_database_license_model" {
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "autonomous_database_wallet_password" {
  default = "MyAutonomousDatabasePassword123"
}


variable "disable_auto_retries" {
  default = "false"
}

variable "private_key_password" {
  default = ""
}
