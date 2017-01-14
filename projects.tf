module "blog" {
  source    = "github.com/OJFord/blog"
  domain    = "ojford.com"
  subdomain = "blog"
}

module "searx" {
  source = "github.com/OJFord/searx"
  domain = "ojford.com"
  host   = "${scaleway_server.aedile.public_ip}"
}
