package terraform.flow_checks

import data.terraform.library
import rego.v1

# Retrieve `davinci_flow` resources with a specific action (e.g., "create")
get_relevant_flows(action) = flows if {
    flows := [flow |
        flow := library.get_resources_by_type_and_action("davinci_flow", action)[_];
        is_object(flow.change.after)  # Ensure `after` is an object
    ]
    # print("Relevant flows retrieved with action:", action, "flows:", flows)  # Debugging output
}

# Check if `deploy` is true for all flows in the input list
deploy_is_true_for_all(flows) if {
    print("Checking deploy field for each relevant flow.")
    all_true := [flow |
        flow := flows[_];
        deploy_value := object.get(flow.change.after, "deploy", false)
        # print("Flow deploy value:", deploy_value)  # Print the actual deploy value for each flow
        # print("Deploy value is boolean?", is_boolean(deploy_value))  # Debugging output
        deploy_value == true
    ]
    # print("Flows with deploy set to true:", all_true)  # Debugging output
    # print("Count of flows with deploy true:", count(all_true))
    # print("Total number of flows:", count(flows))
    count(all_true) == count(flows)
    # print("Does count(all_true) == count(flows)?", count(all_true) == count(flows))  # Debugging output
}

# Check if all flow names start with a given prefix
name_starts_with_prefix(flows, prefix) if {
    all_prefixed := [flow |
        flow := flows[_];
        startswith(flow.change.after.name, prefix)
    ]
    # print("Flows with names starting with prefix:", prefix, "flows:", all_prefixed)  # Debugging output
    count(all_prefixed) == count(flows)
}
