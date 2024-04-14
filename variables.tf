variable "ssh_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Local Public SSH key for setting up auth"
}

## traefik / TLS
variable "stack_config" {
  type = object({
    domain_name: string
    dns_api_key: string
    cert_postmaster_name: string
    pushover_url: string
    hostname: string
    staging: bool
  })
}

## Proxmox vars
variable "pve_node_name" {
  type        = string
  description = "Node name (default is pve)"
  default     = "pve"
}

variable "pve_endpoint" {
  type        = string
  description = "Node endpoint (HTTPS)"
}

variable "pve_token" {
  type        = string
  description = "The token for the Proxmox Virtual Environment API"
  default     = null
}

variable "pve_ip" {
  type        = string
}


# container vars
variable "ct_tags" {
  type = list(string)
}

variable "ct_network" {
  type = object({
    network  = string
    gateway  = string
    net_mask = number
    dns = list(string)
  })
}

variable "ct_config" {
  description = "Template LXC with docker"
  type        = object({
    id             = number
    hostname       = string
    cpus           = number
    memory         = number
    disk_size      = number # in Gigabytes
    bridge         = string
    hostnum        = number
    mac_addr       = string
    vlan           = number
    nic_rate_limit = number
  })
}


variable "ct_datastore_storage_location" {
  type = string
}
variable "ct_datastore_template_location" {
  type = string
}
variable "ct_start_on_boot" {
  type    = bool
  default = true
}
variable "ct_source_file_path" {
  type = string
}
variable "os_type" {
  type = string
}
variable "tmp_dir" {
  type = string
}
