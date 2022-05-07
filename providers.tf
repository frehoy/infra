terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.33.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.19.2"
    }
  }
}


variable "hcloud_token" {
  # Sourced from environment variable TF_VAR_hcloud_token
  sensitive = true
}

provider "hcloud" {
  token = var.hcloud_token
}
