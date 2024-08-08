DEV_DIR:=./terraform

# dvlint options
DVLINT_RULE_PACK:=@ping-identity/dvlint-base-rule-pack
DVLINT_EXCLUDE_RULES:=dv-rule-logo-001
DVLINT_INCLUDE_RULES:=
DVLINT_IGNORE_RULES:=dv-rule-annotations-001,dv-rule-empty-flow-001
default: devcheck


check-for-terraform:
	@command -v terraform >/dev/null 2>&1 || { echo >&2 "'terraform' is required but not installed. Aborting."; exit 1; }

fmt: check-for-terraform
	@echo "==> Formatting Terraform code with terraform fmt..."
	@terraform fmt -recursive .

fmt-check: check-for-terraform
	@echo "==> Checking Terraform code with terraform fmt..."
	@terraform fmt -recursive -check .

tflint:
	@echo "==> Checking Terraform code with tflint..."
	@command -v tflint >/dev/null 2>&1 || { echo >&2 "'tflint' is required but not installed. Aborting."; exit 1; }
	@tflint --recursive

dvlint:
	@echo "==> Checking DaVinci Flows with dvlint..."
	@command -v jq >/dev/null 2>&1 || { echo >&2 "'jq' is required but not installed. Aborting."; exit 1; }
	@command -v dvlint >/dev/null 2>&1 || { echo >&2 "'dvlint' is required but not installed. Aborting."; exit 1; }
	@find . -name '*.json' | while read -r file; do \
		if jq -e -r '.companyId' $$file >/dev/null; then \
			dvlint -f $$file \
				--rulePacks "$(DVLINT_RULE_PACK)" \
				--excludeRule "$(DVLINT_EXCLUDE_RULES)" \
				--ignoreRule "$(DVLINT_IGNORE_RULES)" \
				--includeRule "$(DVLINT_INCLUDE_RULES)" \
				|| exit 1; \
		fi; \
	done


validate: check-for-terraform
	@echo "==> Validating Terraform code with terraform validate..."
	@if [ -d "./$(DEV_DIR)" ]; then \
		terraform -chdir=$(DEV_DIR) validate; \
	fi

trivy:
	@echo "==> Checking Terraform code with trivy..."
	@command -v trivy >/dev/null 2>&1 || { echo >&2 "'trivy' is required but not installed. Aborting."; exit 1; }
	@trivy config ./

devcheck: fmt fmt-check validate tflint dvlint trivy

.PHONY: devcheck fmt fmt-check validate tflint dvlint trivy