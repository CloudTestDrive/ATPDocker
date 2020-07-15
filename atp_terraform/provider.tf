provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
  region               = var.region
  disable_auto_retries = var.disable_auto_retries
}


# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Output the result
output "show-ads" {
  value = data.oci_identity_availability_domains.ads.availability_domains
}

data "oci_database_autonomous_database_wallet" "my_autonomous_database_wallet" {
    #Required
    autonomous_database_id = oci_database_autonomous_database.my_autonomous_database.id
    password = var.autonomous_database_wallet_password
}

resource "local_file" "db_wallet" {
    content     = data.oci_database_autonomous_database_wallet.my_autonomous_database_wallet.content
    filename = "./myWallet.zip"
}
