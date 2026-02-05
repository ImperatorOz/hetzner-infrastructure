variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cax11"
}
