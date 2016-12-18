module "searx" {
  source = "github.com/OJFord/searx"
  domain = "ojford.com"
  host   = "${scaleway_server.aedile.public_ip}"
}
