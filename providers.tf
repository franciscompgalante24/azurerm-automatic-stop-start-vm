# ---------------------------------------------------------
# PROVIDERS
# ---------------------------------------------------------

terraform {
  required_version = "1.5.1"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 1.0"
    }
  }
}
