
resource "oci_containerengine_cluster" "k8s_cluster" {
	compartment_id = var.compartment_ocid
	kubernetes_version = "v1.16.8"
	name = format("%s_%s_%d",var.OKE_Name,var.Participant_Initials, count.index)
	vcn_id = oci_core_virtual_network.K8SVNC.id

	count = var.OKE_Cluster_Nb

	options {

		add_ons {
			is_kubernetes_dashboard_enabled = true
			is_tiller_enabled = true
		}
		service_lb_subnet_ids = [oci_core_subnet.LoadBalancerSubnet.id]
	}
}

data "oci_containerengine_node_pool_option" "test_node_pool_option" {
	  node_pool_option_id = "all"
	}

locals {
	 	ad_nums2 = [
			for ad_key in range(length(data.oci_identity_availability_domains.ads.availability_domains)) :
	      	lookup(data.oci_identity_availability_domains.ads.availability_domains[ad_key],"name")
			]
	  all_sources = data.oci_containerengine_node_pool_option.test_node_pool_option.sources
    oracle_linux_images = [for source in local.all_sources : source.image_id if length(regexall("Oracle-Linux-[0-9]*.[0-9]*-20[0-9]*",source.source_name)) > 0]
	}


resource "oci_containerengine_node_pool" "K8S_pool1" {
	#Required
	count = var.OKE_Cluster_Nb
	cluster_id = oci_containerengine_cluster.k8s_cluster[count.index].id
	compartment_id = var.compartment_ocid
  kubernetes_version = "v1.16.8"
	name = "K8S_pool1"
	node_shape = var.k8sWorkerShape

	node_config_details {
		dynamic "placement_configs" {
			for_each = local.ad_nums2

			content {
				availability_domain = placement_configs.value
				subnet_id           = oci_core_subnet.workerSubnet.id
				}
		}
    size = 3
	}

#	ssh_public_key = var.node_pool_ssh_public_key

node_source_details {
    #Required
    image_id    = local.oracle_linux_images.0
    source_type = "IMAGE"
  }

}



data "oci_containerengine_cluster_kube_config" "test_cluster_kube_config" {
  #Required
  cluster_id = oci_containerengine_cluster.k8s_cluster[count.index].id
	token_version = "2.0.0"
	count = var.OKE_Cluster_Nb
}

resource "local_file" "mykubeconfig" {
	count = var.OKE_Cluster_Nb
  content  = data.oci_containerengine_cluster_kube_config.test_cluster_kube_config[count.index].content
	filename = format("./mykubeconfig_%d",count.index)
}
