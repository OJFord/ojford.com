provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

provider "mailgun" {
  api_key = "${var.mailgun_api_key}"
}

provider "scaleway" {
  organization = "${var.scaleway_access_key}"
  access_key   = "${var.scaleway_token}"
  region       = "${var.scaleway_region}"
}
