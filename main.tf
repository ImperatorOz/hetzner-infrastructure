terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Upload your SSH key to Hetzner
resource "hcloud_ssh_key" "default" {
  name       = "terraform-key"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "app" {
  name        = "app-${var.env}"
  image       = "ubuntu-22.04"
  server_type = var.server_type
  location    = "hel1" 
  
  # Attach the key to the server
  ssh_keys    = [hcloud_ssh_key.default.id]
}
