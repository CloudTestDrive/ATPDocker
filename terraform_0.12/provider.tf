provider "oci" {
  version              = ">= 3.27.0"
  region               = var.region
  disable_auto_retries = var.disable_auto_retries
}

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}
