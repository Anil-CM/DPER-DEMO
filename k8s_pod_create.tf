terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.0.0"
    }
  }
}

# Configure the Access Group provider
provider "ibm" {
  ibmcloud_api_key = var.user_apikey
}

# Configure the Kubernetes provider
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.cluster_id
  download        = true
}

provider "kubernetes" {
  config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
}

# Define the Kubernetes Pod resource
resource "kubernetes_pod" "ubuntu" {
  metadata {
    name = "ubuntu"

  }

  spec {
    container {
      image   = "ubuntu"
      name    = "ubuntu"
      command = ["/bin/sleep", "30000"]
    }
  }
}
