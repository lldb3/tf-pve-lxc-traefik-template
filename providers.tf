## https://github.com/bpg/terraform-provider-proxmox/blob/7e7333b67a3a4d9bf3f8b1915a8bf94bd0bdf588/docs/resources/virtual_environment_vm.md
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~>0.46.6"
    }

    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }

  }
}

#################################################################### Providers
provider "proxmox" {
  endpoint  = var.pve_endpoint
  insecure  = true # tls trust
  api_token = var.pve_token
  ssh {
    agent = true
    #    username = "root"
  }
}

