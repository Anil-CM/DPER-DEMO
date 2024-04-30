# 1. read input template config
# 2. identify the resources - done
# 3. get the access policy roles and service maps for the resource for each resource in the config
# 4. generate access group, access group memeber, access group policy templates for each resource
# 5. add the dependencies block in the input resource template and terraform data
# 6. add provider alias and parent child info in resources

import jinja2
import sys
resource_acess_role_map = {
    'kubernetes_pod' : {
        'service': "containers-kubernetes",
        'roles': ["Administrator", "Manager"]
    }
}

def list_resources(tf_config_file):
    # Read the Terraform configuration file
    try:
        with open(tf_config_file, "r") as f:
            config = f.readlines()
    except IOError as e:
        print(e)
        return
    
    # Find the resource block that you want to add the depends_on attribute to
    resources_list = []
    resource = 'resource'
    for i, line in enumerate(config):
        if line.startswith(resource):
            arr = line.split(" ")
            resources_list.append(
                {
                    'resource_type': arr[1].replace('"', ''),
                    'resource_name': arr[2].replace('"', '')
                },
            )
    print(resources_list)
    return resources_list

def generate_access_group_resources_template(resources, input_file):
    # iterate through the resources list
    content = """

provider "ibm" {
  alias            = "parent"
  ibmcloud_api_key = var.parent_apikey 
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

"""

    for resource in resources:
        # get the resource access roles mapping
        ag_pol_input = resource_acess_role_map[resource['resource_type']]
        print(ag_pol_input)
        with open("access_policy_template.jinja2", "r") as f:
            template = jinja2.Template(f.read())
        res_addr = resource['resource_type']+'.'+resource['resource_name']
        rendered_template = template.render(
            roles=ag_pol_input['roles'],
            name=resource['resource_type']+'_'+resource['resource_name'],
            service=ag_pol_input['service'],
            resource_address=res_addr
        )
        dependency = "ibm_iam_access_group_policy.elevate_access_" + resource['resource_type']+'_'+resource['resource_name']
        content = content + "\n" + rendered_template
        add_depends_on(res_addr, input_file, dependency)


    
    with open("access_group_resources.tf", 'w') as fh:
        fh.write(content)


def add_depends_on(resource_address, filename, dependency):
    # Read the Terraform configuration file
    try:
        with open(filename, "r") as f:
            config = f.readlines()
    except IOError as e:
        print(e)
        return
    
    # Find the resource block that you want to add the depends_on attribute to
    resource_block_index = -1
    arr = resource_address.split(".")
    resource = 'resource '+ '"'+arr[0]+ '" '+ '"'+ arr[1] +'"'
    print("resource = ", resource)
    for i, line in enumerate(config):
        if line.startswith(resource):
            resource_block_index = i
            break

    # If the resource block was not found, exit the program
    if resource_block_index == -1:
        print("Could not find resource block")
        return

    # Insert the depends_on attribute to the resource block
    config.insert(resource_block_index + 1, "\tdepends_on = ["+ dependency +"]\n")

    # Write the updated configuration file
    try:
        with open(filename, "w") as f:
            f.writelines(config)
    except IOError as e:
        print(e)
        return

    print("Updated input Terraform configuration file")


if __name__ == "__main__":
    input_file = sys.argv[1]
    resources = list_resources(input_file)
    generate_access_group_resources_template(resources, input_file)

