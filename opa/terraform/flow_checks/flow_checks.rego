# DISCLAIMER: This file is intended for demonstration and example purposes only.
# It is provided "as is" without any warranties or guarantees of accuracy or fitness for use.
# Use at your own risk and adapt to your specific requirements before production use.

package terraform.flow_checks

import data.terraform.library
import rego.v1

# Alias the input as `resources` for readability
resources := input.resource_changes # Explicitly access resources from input

# Retrieve `davinci_flow` resources with a specific action (e.g., "create")
relevant_flows(resources, actions) := [flow |
	some flow in library.resources_by_type(resources, "davinci_flow") # Pass resources explicitly
	some action in actions # Check if any action matches
	action in flow.change.actions
	is_object(flow.change.after) # Ensure `after` is an object
	# print("Relevant flows retrieved with actions:", actions, "flows:", flows)  # Debugging output
]

# Check if `deploy` is true for all flows in the input list
deploy_is_true_for_all(flows) if {
	#   print("Checking deploy field for each relevant flow.")
	all_true := [flow |
		some flow in flows
		deploy_value := object.get(flow.change.after, "deploy", false)

		# print("Flow deploy value:", deploy_value)  # Print the actual deploy value for each flow
		deploy_value == true
	]

	# print("Flows with deploy set to true:", all_true)  # Debugging output
	# print("Count of flows with deploy true:", count(all_true)) # Debugging output
	# print("Total number of flows:", count(flows)) # Debugging output
	count(all_true) == count(flows)
	# print("Does count(all_true) == count(flows)?", count(all_true) == count(flows))  # Debugging output
}

# Check if all flow names start with a given prefix
name_starts_with_prefix(flows, prefix) if {
	all_prefixed := [flow |
		some flow in flows
		startswith(flow.change.after.name, prefix)
	]

	# print("Flows with names starting with prefix:", prefix, "flows:", all_prefixed)  # Debugging output
	count(all_prefixed) == count(flows)
}
