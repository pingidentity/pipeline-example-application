# DISCLAIMER: This file is intended for demonstration and example purposes only.
# It is provided "as is" without any warranties or guarantees of accuracy or fitness for use.
# Use at your own risk and adapt to your specific requirements before production use.

package terraform.davinci_test

import data.terraform.davinci
import rego.v1

# Mock data for testing the `deny` rules
input_all_pass := {"resource_changes": [{
	"type": "davinci_flow",
	"change": {
		"actions": ["create"],
		"after": {
			"deploy": true,
			"name": "AppTeam Registration Flow",
		},
	},
}]}

input_deploy_fail := {"resource_changes": [{
	"type": "davinci_flow",
	"change": {
		"actions": ["update"],
		"after": {
			"deploy": false,
			"name": "AppTeam Registration Flow",
		},
	},
}]}

input_name_prefix_fail := {"resource_changes": [{
	"type": "davinci_flow",
	"change": {
		"actions": ["create"],
		"after": {
			"deploy": true,
			"name": "NonAppTeam Registration Flow", # Should fail because name does not start with "AppTeam"
		},
	},
}]}

# Test where all conditions pass
test_all_conditions_pass if {
	davinci.deny with input as input_all_pass # Expect no deny messages
}

# Test where `deploy` fails
test_deploy_fail if {
	davinci.deny with input as input_deploy_fail # Expect a deny message because deploy is false
}

# # Test where name prefix fails
test_name_prefix_fail if {
	davinci.deny with input as input_name_prefix_fail # Expect a deny message because name does not start with "AppTeam"
}
