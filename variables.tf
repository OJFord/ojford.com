variable "cloudflare_email" {
  type = "string"
}

variable "cloudflare_token" {
  type = "string"
}

variable "scaleway_access_key" {
  type = "string"
}

variable "scaleway_token" {
  type = "string"
}

variable "scaleway_region" {
  type    = "string"
  default = "par1"
}

variable "aedile_server_type" {
  type    = "string"
  default = "VC1S"
}

variable "github_webhook_key" {
  type = "string"
}
