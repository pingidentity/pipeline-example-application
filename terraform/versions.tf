terraform {
  required_version = ">= 1.6.0"
  required_providers {
    pingone = {
      source  = "pingidentity/pingone"
      version = "~> 1.0.0"
    }
    davinci = {
      source  = "pingidentity/davinci"
      version = ">= 0.2.1, < 1.0.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
  backend "s3" {
  }
}

