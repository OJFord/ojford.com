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

resource "scaleway_ip" "aedile" {
  server = "${scaleway_server.aedile.id}"
}

resource "scaleway_server" "aedile" {
  name  = "aedile"
  type  = "${var.aedile_server_type}"
  image = "${data.scaleway_image.docker.id}"
}

resource "null_resource" "aedile_systemd" {
  triggers {
    server_id = "${scaleway_server.aedile.id}"
    service   = "${base64sha256(file("${path.module}/caddy.service.erb"))}"
  }

  connection {
    type = "ssh"
    host = "${scaleway_server.aedile.public_ip}"
    user = "root"
  }

  provisioner "local-exec" {
    command = <<EOF
      BASIC_AUTH_USER=${var.basic_auth_user} \
      BASIC_AUTH_PSWD=${var.basic_auth_pswd} \
      CLOUDFLARE_EMAIL=${var.cloudflare_email} \
      CLOUDFLARE_API_KEY=${var.cloudflare_token} \
      GITHUB_WEBHOOK_KEY=${var.github_webhook_key} \
      erb caddy.service.erb > /tmp/caddy.service
    EOF
  }

  provisioner "file" {
    source      = "/tmp/caddy.service"
    destination = "/etc/systemd/system/caddy.service"
  }
}

resource "null_resource" "aedile_bootstrap" {
  triggers {
    server_id = "${scaleway_server.aedile.id}"
    script    = "${base64sha256(file("${path.module}/bootstrap.sh"))}"
    conf      = "${base64sha256(file("${path.module}/Caddyfile"))}"
  }

  depends_on = [
    "null_resource.aedile_systemd",
  ]

  connection {
    type = "ssh"
    host = "${scaleway_server.aedile.public_ip}"
    user = "root"
  }

  provisioner "remote-exec" {
    script = "bootstrap.sh"
  }
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name         = "Docker"
}
