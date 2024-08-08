##############################################
# PingOne Module
##############################################
# PingOne Utilities Module
# {@link https://registry.terraform.io/modules/pingidentity/utils/pingone/latest}
module "pingone_utils" {
  source  = "pingidentity/utils/pingone"
  version = "0.1.0"

  environment_id = var.pingone_target_environment_id
  region_code    = var.pingone_client_region_code
}

##############################################
# PingOne Provider
##############################################
# {@link https://registry.terraform.io/providers/pingidentity/pingone/latest/docs}

provider "pingone" {
  client_id      = var.pingone_client_id
  client_secret  = var.pingone_client_secret
  environment_id = var.pingone_client_environment_id
  region_code    = var.pingone_client_region_code
}

provider "davinci" {
  username       = var.pingone_davinci_admin_username
  password       = var.pingone_davinci_admin_password
  region         = var.pingone_davinci_admin_region
  environment_id = var.pingone_davinci_admin_environment_id
}
