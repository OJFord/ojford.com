#!/bin/bash
set -e

# Addons for the server (space separated)
caddy_features="git cloudflare"

repo_name="ojford.com"
repo="/var/git/$repo_name"
served="/var/www/$repo_name"

if ! hash caddy 2>/dev/null; then
    echo "Installing Caddy with: $caddy_features..."
    build_params="os=linux&arch=amd64&features=${caddy_features// /%2C}"
    curl "https://caddyserver.com/download/build?$build_params" -o /tmp/caddy.gz
    tar -xvf /tmp/caddy.gz --directory=/tmp
    mv /tmp/caddy /usr/local/bin

    echo "Setting Caddy permissions..."
    chmod 755 /usr/local/bin/caddy

    echo "Setting Caddy to run on startup..."
    chmod 644 /etc/systemd/system/caddy.service
    systemctl enable caddy

    echo "Giving Caddy  access to ports <1024..."
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

    echo "Setting Caddy to clone & run $repo..."
    mkdir -p /etc/caddy
    # Dummy Caddyfile that serves only to clone the repo with the real one
    cat << END_CF > /etc/caddy/Caddyfile
ojford.com
tls off
git {
    repo https://github.com/OJFord/$repo_name
    path $repo
    hook /gh_webhook $GITHUB_WEBHOOK_KEY
    then git --git-dir=$repo/.git checkout-index -a -f --prefix=$served/
    then ln -sf $served/Caddyfile /etc/caddy/Caddyfile 
}
END_CF
    mkdir -p "$repo" "$served"

    echo "Setting permissions on Caddy data..."
    chown -R root:www-data /etc/caddy
    chmod 444 /etc/caddy/Caddyfile

    echo "Setting permissions on Caddy SSL data..."
    mkdir -p /etc/ssl/caddy
    chown -R www-data:root /etc/ssl/caddy
    chmod 0770 /etc/ssl/caddy

    echo "Changing misc. Caddy-recommended settings..."
    ulimit -n 8192
fi
