# DISCLAIMER: This file is intended for demonstration and example purposes only.
# It is provided "as is" without any warranties or guarantees of accuracy or fitness for use.
# Use at your own risk and adapt to your specific requirements before production use.

package terraform.library_test

import data.terraform.library
import rego.v1

# Mock data for testing
mock_resources := [
	{"type": "aws_instance", "name": "instance-1", "change": {"actions": ["create"]}},
	{"type": "aws_s3_bucket", "name": "bucket-1", "change": {"actions": ["create"]}},
	{"type": "aws_instance", "name": "instance-2", "change": {"actions": ["delete"]}},
	{"type": "aws_s3_bucket", "name": "bucket-2", "change": {"actions": ["update"]}},
]

# Test resources_by_type
test_resources_by_type if {
	result := library.resources_by_type(mock_resources, "aws_instance")
	result == [
		{"type": "aws_instance", "name": "instance-1", "change": {"actions": ["create"]}},
		{"type": "aws_instance", "name": "instance-2", "change": {"actions": ["delete"]}},
	]
}

# Test resources_by_action
test_resources_by_action if {
	result := library.resources_by_action(mock_resources, "create")
	result == [
		{"type": "aws_instance", "name": "instance-1", "change": {"actions": ["create"]}},
		{"type": "aws_s3_bucket", "name": "bucket-1", "change": {"actions": ["create"]}},
	]
}

# Test resources_by_type_and_action
test_resources_by_type_and_action if {
	result := library.resources_by_type_and_action(mock_resources, "aws_instance", "delete")
	result == [{"type": "aws_instance", "name": "instance-2", "change": {"actions": ["delete"]}}]
}

# Test resource_by_name
test_resource_by_name if {
	result := library.resource_by_name(mock_resources, "bucket-1")
	result == [{"type": "aws_s3_bucket", "name": "bucket-1", "change": {"actions": ["create"]}}]
}

# Test resource_by_type_and_name
test_resource_by_type_and_name if {
	result := library.resource_by_type_and_name(mock_resources, "aws_s3_bucket", "bucket-2")
	result == [{"type": "aws_s3_bucket", "name": "bucket-2", "change": {"actions": ["update"]}}]
}
