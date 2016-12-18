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
