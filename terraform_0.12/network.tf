

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}


resource "oci_core_virtual_network" "K8SVNC" {
  cidr_block     = var.VPC-CIDR
  compartment_id = var.compartment_ocid
  display_name = format("%s_%s",var.OKE_Network_name,var.Participant_Initials)
  dns_label      = "k8s"
}


resource "oci_core_internet_gateway" "K8SIG" {
  compartment_id = var.compartment_ocid
  display_name   = "K8S-IG"
  vcn_id         = oci_core_virtual_network.K8SVNC.id
}

resource "oci_core_default_route_table" "RouteForK8S" {
  display_name   = "RouteTableForK8SVNC"
  manage_default_resource_id = oci_core_virtual_network.K8SVNC.default_route_table_id
  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.K8SIG.id
  }
}

resource "oci_core_security_list" "WorkerSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "WorkerSecList"
  vcn_id         = oci_core_virtual_network.K8SVNC.id

  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-fra-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = "10.0.0.0/28"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

}

resource "oci_core_security_list" "LoadBalancerSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "LoadBalancerSecList"
  vcn_id         = oci_core_virtual_network.K8SVNC.id

  ingress_security_rules {
     protocol = "6"
     source   = "0.0.0.0/0"
     stateless = true
   }

   ingress_security_rules {
     protocol = "6"
     source   = "0.0.0.0/0"
     stateless = false
     tcp_options {
       min = 80
       max = 80
       }
   }

   ingress_security_rules {
     protocol = "6"
     source   = "0.0.0.0/0"
     stateless = false
     tcp_options {
       min = 443
       max = 443
       }
   }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
    stateless = false
  }

}

resource "oci_core_security_list" "k8sendpointSecList" {
  compartment_id = var.compartment_ocid
  display_name   = "k8sendpointSecList"
  vcn_id         = oci_core_virtual_network.K8SVNC.id

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-fra-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  freeform_tags = {
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.10.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

}

resource "oci_core_subnet" "workerSubnet" {
  cidr_block          = lookup(var.network_cidrs, "workerSubnetAD1")
  display_name        = "workerSubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.K8SVNC.id
  route_table_id      = oci_core_default_route_table.RouteForK8S.id
  security_list_ids   = [oci_core_security_list.WorkerSecList.id]
  dhcp_options_id     = oci_core_virtual_network.K8SVNC.default_dhcp_options_id
  dns_label           = "worker"
}

resource "oci_core_subnet" "LoadBalancerSubnet" {
  cidr_block          = lookup(var.network_cidrs, "LoadBalancerSubnetAD1")
  display_name        = "LoadBalancerSubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.K8SVNC.id
  route_table_id      = oci_core_default_route_table.RouteForK8S.id
  security_list_ids   = [oci_core_security_list.LoadBalancerSecList.id]
  dhcp_options_id     = oci_core_virtual_network.K8SVNC.default_dhcp_options_id
  dns_label           = "loadbalancer"
}

resource "oci_core_subnet" "k8sendpointSubnet" {
  cidr_block          = lookup(var.network_cidrs, "k8sendpointSubnet")
  display_name        = "k8sendpointSubnet"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.K8SVNC.id
  route_table_id      = oci_core_default_route_table.RouteForK8S.id
  security_list_ids   = [oci_core_security_list.k8sendpointSecList.id]
  dhcp_options_id     = oci_core_virtual_network.K8SVNC.default_dhcp_options_id
  dns_label           = "k8sendpoint"
}
