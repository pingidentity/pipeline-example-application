# DISCLAIMER: This file is intended for demonstration and example purposes only.
# It is provided "as is" without any warranties or guarantees of accuracy or fitness for use.
# Use at your own risk and adapt to your specific requirements before production use.

package terraform.library

import rego.v1

# Creating alias for input as 'resources' for readability
resources := input.resource_changes

# METADATA
# description: |
#  A set of helper functions to work with Terraform resources.
#  Provided as examples for the CICD application pipeline only
#  These functions can be used to filter resources by type, action, name, and so on.
# authors:
# - name: Ping Devops Initiatives (PDI)
# related_resources:
# - https://docs.styra.com/regal

# METADATA
# title: Resources By Type
# description: Retrieves all resources of a specific type from the input.
resources_by_type(resources, type) := [resource |
	some resource in resources
	resource.type == type
]

# METADATA
# title: Resources By Action
# description: Retrieves all resources that include a specified action in their change actions.
resources_by_action(resources, action) := [resource |
	some resource in resources
	action in resource.change.actions
]

# METADATA
# title: Resources By Type and Action
# description: Retrieves all resources of a specific type that include a specified action in their change actions.
resources_by_type_and_action(resources, type, action) := [resource |
	some resource in resources
	resource.type == type
	action in resource.change.actions
]

# METADATA
# title: Resource By Name
# description: Retrieves the resource with a specified name from the input.
resource_by_name(resources, resource_name) := [resource |
	some resource in resources
	resource.name == resource_name
]

# METADATA
# title: Resource By Type and Name
# description: Retrieves the resource of a specific type with a specified name.
resource_by_type_and_name(resources, type, resource_name) := [resource |
	some resource in resources
	resource.type == type
	resource.name == resource_name
]
