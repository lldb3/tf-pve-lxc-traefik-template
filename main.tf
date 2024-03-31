resource "random_password" "container_root_password" {
  length           = 24
  override_special = "_%@"
  special          = true
}

output "container_root_password" {
  value     = random_password.container_root_password.result
  sensitive = true
}

# location of containers templates
resource "proxmox_virtual_environment_file" "debian_container_template" {
  content_type = "vztmpl"
  datastore_id = var.ct_datastore_template_location
  node_name    = var.pve_node_name
  source_file {
    path = var.ct_source_file_path
  }
}

resource "proxmox_virtual_environment_container" "lxc_container" {
  description   = "(testing container) managed by Terraform"
  node_name     = var.pve_node_name
  start_on_boot = var.ct_start_on_boot
  tags          = var.ct_tags
  unprivileged  = true
  vm_id         = var.ct_config.id
  cpu {
    architecture = "amd64"
    cores        = var.ct_config.cpus
  }

  disk {
    datastore_id = var.ct_datastore_storage_location
    size         = var.ct_config.disk_size
  }

  memory {
    dedicated = var.ct_config.memory
    swap      = 0
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_file.debian_container_template.id
    type             = var.os_type
  }

  initialization {
    hostname = var.ct_config.hostname
    dns {
      servers = var.ct_network.dns
    }

    ip_config {
      ipv4 {
        address = join("/", [cidrhost(var.ct_network.network, var.ct_config.hostnum), var.ct_network.net_mask])
        gateway = var.ct_network.gateway
      }
    }
    user_account {
      keys     = [file("~/.ssh/id_rsa.pub"),]
      password = random_password.container_root_password.result
    }
  }
  network_interface {
    name        = "eth0"
    bridge      = var.ct_config.bridge
    rate_limit  = var.ct_config.nic_rate_limit
    mac_address = var.ct_config.mac_addr
    vlan_id = var.ct_config.vlan
  }
  features {
    nesting = true
    fuse    = false
  }
}


resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible/inventory"
  file_permission = "0644"

  content = <<-EOT
    [lxc_container]
    lxc_ct_01 ansible_host=${cidrhost(var.ct_network.network, var.ct_config.hostnum)}

    [all:vars]
    traefik_domain_name=${var.stack_config.domain_name}
    dns_challenge_api_token=${var.stack_config.dns_api_key}
    cert_postmaster_name=${var.stack_config.cert_postmaster_name}
    pushover_url=${var.stack_config.pushover_url}
    staging=${var.stack_config.staging}
    mediaserver_lxc_id=${var.ct_config.id}
    mediaserver_lxc_ip=${cidrhost(var.ct_network.network, var.ct_config.hostnum)}
EOT
}

resource "null_resource" "ansible_provision" {
  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_FORCE_COLOR=true \
      ansible-playbook -i ${local_file.ansible_inventory.filename} \
      -u root \
      -e ignore_host_key_checking=True \
      ${path.module}/ansible/site.yml
    EOT
  }

  triggers = {
    always_run = timestamp() # runs every time apply is called
  }

  depends_on = [
    local_file.ansible_inventory, proxmox_virtual_environment_container.lxc_container
  ]
}



