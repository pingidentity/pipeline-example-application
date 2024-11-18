package terraform.library

import rego.v1

# Importing resources from input for readability
import input.resource_changes as resources

# Get resources by type
get_resources_by_type(type) = filtered_resources if {
    filtered_resources := [resource | resource := resources[_]; resource.type == type]
}

# Get resources by action
get_resources_by_action(action) = filtered_resources if {
    filtered_resources := [resource | resource := resources[_]; action in resource.change.actions]
}

# Get resources by type and action
get_resources_by_type_and_action(type, action) = filtered_resources if {
    filtered_resources := [resource | resource := resources[_]; resource.type == type; action in resource.change.actions]
}

# Get resource by name
get_resource_by_name(resource_name) = filtered_resources if {
    filtered_resources := [resource | resource := resources[_]; resource.name == resource_name]
}

# Get resource by type and name
get_resource_by_type_and_name(type, resource_name) = filtered_resources if {
    filtered_resources := [resource | resource := resources[_]; resource.type == type; resource.name == resource_name]
}
