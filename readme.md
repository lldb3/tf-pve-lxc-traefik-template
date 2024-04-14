
# tf-pve-lxc-treafik-template

A terraform template for docker in LXC with traefik.

Sets up an unprivileged LXC container in a proxmox environment using terraform.

- LXC setup with terraform
- ansible inventory creation with the terraform output
- ansible used to install SSH, Docker, and setup up traefik
- traefik DNS Challenge with provided variables (see terafform.tfvars.example)
- watchtower can be enabled (comment out in [jinja template file](./ansible/roles/traefik/templates/compose.yml.j2))


### Usage

Populate tfvars file with custom values and removoe the .example in the filename.


```shell
terraform init -upgrade
terraform plan -out plan
terraform apply plan
```

