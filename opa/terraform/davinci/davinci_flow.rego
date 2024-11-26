# DISCLAIMER: This file is intended for demonstration and example purposes only.
# It is provided "as is" without any warranties or guarantees of accuracy or fitness for use.
# Use at your own risk and adapt to your specific requirements before production use.

package terraform.davinci

import data.terraform.flow_checks
import rego.v1

resources := input.resource_changes # Explicitly access resources from input

# Retrieve all relevant flows with the "create" or "update" action
relevant_flows := flow_checks.relevant_flows(resources, ["create", "update"])

# Check if `deploy` is true for all relevant flows
deploy_true if {
	# print("Checking if deploy is true for all relevant flows:", relevant_flows) # Debugging output
	flow_checks.deploy_is_true_for_all(relevant_flows)
}

# Check if all flow names start with "AppTeam"
name_starts_with_appteam if {
	# print("Checking if all relevant flows start with 'AppTeam':", relevant_flows) # Debugging output
	flow_checks.name_starts_with_prefix(relevant_flows, "AppTeam")
}

# METADATA
# title: Davinci Flow "Master" rule set
# description: Determine if all 'davinci_flow' resources meet the required conditions.
# entrypoint: true
deny[msg] if {
	not deploy_true
	msg := "All 'davinci_flow' resources must have 'deploy' set to true."
	# print("Deny triggered for deploy:", msg)  # Debugging output
}

# Deny if any flow name does not start with "AppTeam"
deny[msg] if {
	not name_starts_with_appteam
	msg := "All 'davinci_flow' resources must have names starting with 'AppTeam'."
	# print("Deny triggered for name prefix:", msg)  # Debugging output
}
