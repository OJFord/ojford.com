provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

resource "cloudflare_record" "www" {
  domain  = "ojford.com"
  name    = "www"
  value   = "ojford.com"
  type    = "CNAME"
  proxied = "true"
}

resource "cloudflare_record" "bare" {
  domain  = "ojford.com"
  name    = "ojford.com"
  value   = "${scaleway_ip.aedile.ip}"
  type    = "A"
  proxied = "true"
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

resource "null_resource" "aedile" {
  connection {
    type = "ssh"
    host = "${scaleway_server.aedile.public_ip}"
    user = "root"
  }

  provisioner "local-exec" {
    command = <<EOF
      CLOUDFLARE_EMAIL=${var.cloudflare_email}
      CLOUDFLARE_API_KEY=${var.cloudflare_token}
      GITHUB_WEBHOOK_KEY=${var.github_webhook_key}
      erb caddy.service.erb > /tmp/caddy.service
    EOF
  }

  provisioner "file" {
    source      = "/tmp/caddy.service"
    destination = "/etc/systemd/system/caddy.service"
  }

  provisioner "remote-exec" {
    script = "bootstrap.sh"
  }
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name         = "Docker"
}
