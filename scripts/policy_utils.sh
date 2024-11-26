#!/usr/bin/env bash

### this script is a wrapper around OPA policy functions. ###
# shellcheck disable=SC3010

test -f scripts/lib.sh || {
    echo "Please run the script from the root of the repository"
    exit 1
}

export TFDIR="terraform"
export OPADIR="opa"

usage() {
    cat << END_USAGE
Usage: 
  This helper script provides options for using the \`opa\` utility in this repository locally.
  By default, it will run the test suite for the provided example policies.
  This script should be run from the root of the repository. 
  Terraform secrets (\`localsecrets\` file) should be sourced and exported in the environment

{options}
    where {options} include:
    --plan-and-eval
      Run terraform plan and sample OPA policy evaluation
    --eval-only
      Run the sample OPA policy evaluation only - \`plan.json\` should be present in the OPA directory
    -v|--verbose
      Enable verbose mode for debugging
END_USAGE
    exit 99
}

init_all() {
    # shellcheck source=lib.sh
    . scripts/lib.sh

    checkVars

    _branch=$(git rev-parse --abbrev-ref HEAD)

    if test "$_branch" = "prod" || test "$_branch" = qa; then
        echo "You are on a non-dev branch. Please checkout to your feature branch to run this script."
        exit 1
    fi
}

init_s3() {
    ## S3 state bucket configuration
    ## local aws default profile will be used
    ## Specify the bucket name and region
    ## Necessary for `terraform plan`
    if [ -z "${TF_VAR_tf_state_bucket}" ] || [ -z "${TF_VAR_tf_state_region}" ]; then
        echo "TF_VAR_tf_state_bucket or TF_VAR_tf_state_region is not set. Please set the appropriate variables in your localsecrets file."
        exit 1
    fi
    _bucket_name="${TF_VAR_tf_state_bucket}"
    _region="${TF_VAR_tf_state_region}"
    # shellcheck disable=SC2154
    _key="${TF_VAR_tf_state_key_prefix}/dev/${_branch}/terraform.tfstate"
}

terraform_init() {
    ## terraform init
    terraform -chdir="${TFDIR}" init -migrate-state \
        -backend-config="bucket=${_bucket_name}" \
        -backend-config="region=${_region}" \
        -backend-config="key=${_key}"

    ## run terraform with the required parameters
    echo "Running terraform init for branch: ${_branch}, You will be prompted to enter the required variables."

    export TF_VAR_pingone_environment_name="${_branch}"

    terraform -chdir="${TFDIR}" plan -out=plan.tfplan
    terraform -chdir="${TFDIR}" show -no-color -json plan.tfplan > "${OPADIR}"/plan.json
}

opa_eval() {
    echo ""
    echo ""
    echo "##################################################"
    echo "Running OPA policy evaluation..."
    echo ""
    echo ""
    # We want to continue running the script even if the OPA evaluation fails (|| true)
    # shellcheck disable=SC2015
    cd "${OPADIR}" && opa eval -i plan.json -b . 'data.terraform.davinci.deny' > opa_output.json || true

    # Check if the deny result is non-empty
    deny_result=$(jq '.result[0].expressions[0].value' opa_output.json)

    cd ..

    if [[ "$(echo "$deny_result" | jq -e 'keys | length > 0')" == "true" ]]; then
        echo "Policy Failed: Deny messages found."
        echo "Deny messages:"
        echo "$deny_result" | jq .
        exit 1
    else
        echo "Policy Passed: No deny messages found."
    fi
}

run_policy_tests() {
    # Check if verbose mode is enabled
    if echo "$-" | grep -q x; then
        echo "Running tests in verbose mode..."
        cd "${OPADIR}" && opa test -v -b . && cd ..
    else
        echo "Running tests..."
        cd "${OPADIR}" && opa test -b . && cd ..
    fi
}

exit_usage() {
    echo "$*"
    usage
}

# Flag to track if verbose mode is enabled
verbose_mode=false

# Flag to track if any arguments were provided
arguments_provided=false

while ! test -z "${1}"; do
    case "${1}" in
        --eval-only)
            arguments_provided=true
            opa_eval
            ;;
        --plan-and-eval)
            arguments_provided=true
            init_all
            init_s3
            terraform_init
            opa_eval
            ;;
        --run-policy-tests)
            arguments_provided=true
            run_policy_tests
            ;;
        -v | --verbose)
            verbose_mode=true
            set -x
            ;;
        -h | --help)
            exit_usage ""
            ;;
        *)
            exit_usage "Unrecognized Option"
            ;;
    esac
    shift
done

# Enable verbose mode globally if the flag is set
if [ "$verbose_mode" = true ]; then
    set -x
fi

# Default to `run_tests` if no arguments were provided
if [ "$arguments_provided" = false ]; then
    echo "No options provided. Defaulting to running the sample OPA policy tests..."
    echo "Use --help for more options."
    run_policy_tests
fi
