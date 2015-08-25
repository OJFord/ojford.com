provider "scaleway" {
  organization = "${var.scaleway_access_key}"
  access_key   = "${var.scaleway_token}"
  region       = "${var.scaleway_region}"
}
