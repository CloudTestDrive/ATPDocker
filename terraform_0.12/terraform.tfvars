# OCI authentication

tenancy_ocid = "ocid1.tenancy.oc1.....your_ocid"
compartment_ocid = "ocid1.compartment.oc1.....your_ocid"
fingerprint = "d3:e8:your_fingerprint"

# For Mac and Linux : (comment line below if on windows)
private_key_path = "/Users/your_name/.oci/oci_api_key.pem"

# For Windows: use double \\ in your path, as \ is an escape character in Terraform script
# (uncomment below line and comment out Mac/Linux flavour above if applicable)
# private_key_path = "\\Data\\keys\\API_key\\api_key.pem"

user_ocid = "ocid1.user.oc1.....your_ocid"
region = "eu-frankfurt-1"

k8sWorkerShape = "VM.Standard2.1"
