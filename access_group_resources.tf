

provider "ibm" {
  alias            = "parent"
  ibmcloud_api_key = var.parent
}

# Define the Access Group resource
resource "ibm_iam_access_group" "access_group" {
  provider = ibm.parent
  name     = "dper-access-group"
}


resource "ibm_iam_access_group_members" "add_user" {
  provider        = ibm.parent
  access_group_id = ibm_iam_access_group.access_group.id
  ibm_ids         = [var.user_email]
}



# Define the Access Policy resource
resource "ibm_iam_access_group_policy" "elevate_access_kubernetes_pod_ubuntu" {
  provider        = ibm.parent
  access_group_id = ibm_iam_access_group.access_group.id
  roles           = ["Administrator", "Manager"]
  resources {
    service = "containers-kubernetes"
  }
  depends_on = [ibm_iam_access_group_members.add_user]
}

resource "terraform_data" "reduce_access_kubernetes_pod_ubuntu" {
  triggers_replace = [
    ibm_iam_access_group_policy.elevate_access_kubernetes_pod_ubuntu.id,
  ]

  provisioner "local-exec" {
    environment = {
      access_group_id = ibm_iam_access_group.access_group.id
      base_url        = "https://iam.cloud.ibm.com"
    }

    command = "sh delete_access_group.sh"
  }
  depends_on = [kubernetes_pod.ubuntu]
}