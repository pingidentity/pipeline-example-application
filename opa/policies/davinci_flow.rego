package terraform.davinci

import data.terraform.flow_checks as flow_checks
import rego.v1

# Retrieve all relevant flows with the "create" action
relevant_flows := flow_checks.get_relevant_flows("create")

# Check if `deploy` is true for all relevant flows
deploy_true if {
    print("Checking if deploy is true for all relevant flows:", relevant_flows)
    flow_checks.deploy_is_true_for_all(relevant_flows)
}

# Check if all flow names start with "AppTeam"
name_starts_with_AppTeam if {
    print("Checking if all relevant flows start with 'AppTeam':", relevant_flows)
    flow_checks.name_starts_with_prefix(relevant_flows, "AppTeam")
}

# Deny if `deploy` is not true for all flows
deny[msg] if {
    not deploy_true
    msg := "All 'davinci_flow' resources must have 'deploy' set to true."
    print("Deny triggered for deploy:", msg)  # Debugging output
}

# Deny if any flow name does not start with "AppTeam"
deny[msg] if {
    not name_starts_with_AppTeam
    msg := "All 'davinci_flow' resources must have names starting with 'AppTeam'."
    print("Deny triggered for name prefix:", msg)  # Debugging output
}
