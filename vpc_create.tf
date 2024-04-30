terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.65.0-beta0"
    }
  }
}

# Configure the Access Group provider
provider "ibm" {
  ibmcloud_api_key = var.user_apikey
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60" # Sleep for 60 seconds
  }
  depends_on = [ibm_iam_access_group_policy.elevate_access_ibm_is_vpc_my_vpc]
}

# create vpc
resource "ibm_is_vpc" "my_vpc" {
	depends_on = [ibm_iam_access_group_policy.elevate_access_ibm_is_vpc_my_vpc, null_resource.delay]
  name = var.vpc_name
}

