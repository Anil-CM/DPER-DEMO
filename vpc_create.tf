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

# create vpc
resource "ibm_is_vpc" "my_vpc" {
  name = var.vpc_name
}

