provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "www" {
  domain  = "ojford.com"
  name    = "www"
  value   = "ojford.com"
  type    = "CNAME"
  proxied = "false"
}

resource "cloudflare_record" "bare" {
  domain  = "ojford.com"
  name    = "ojford.com"
  value   = "${scaleway_ip.aedile.ip}"
  type    = "A"
  proxied = "false"
}

provider "scaleway" {
  organization = "${var.scaleway_access_key}"
  access_key   = "${var.scaleway_token}"
  region       = "${var.scaleway_region}"
}

resource "scaleway_ip" "aedile" {
  server = "${scaleway_server.aedile.id}"
}

resource "scaleway_server" "aedile" {
  name  = "aedile"
  type  = "${var.aedile_server_type}"
  image = "${data.scaleway_image.docker.id}"
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name         = "Docker"
}
