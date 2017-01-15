module "blog" {
  source    = "github.com/OJFord/blog"
  domain    = "ojford.com"
  subdomain = "blog"
}

module "mailproxy" {
  source        = "github.com/OJFord/mailproxy"
  domain        = "ojford.com"
  smtp_password = "${var.smtp_password}"
}

module "searx" {
  source = "github.com/OJFord/searx"
  domain = "ojford.com"
  host   = "${scaleway_server.aedile.public_ip}"
}
