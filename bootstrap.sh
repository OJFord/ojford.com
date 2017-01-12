#!/bin/bash
set -e

# Addons for the server (space separated)
caddy_features="git cloudflare"
repo_name="ojford.com"
repo="/var/git/$repo_name"
served="/var/www/$repo_name"

chown www-data:www-data /var/www
usermod --append --groups=docker www-data

if ! hash caddy 2>/dev/null; then
    echo "Installing Caddy with: $caddy_features..."
    build_params="os=linux&arch=amd64&features=${caddy_features// /%2C}"
    curl "https://caddyserver.com/download/build?$build_params" -o /tmp/caddy.gz
    tar -xvf /tmp/caddy.gz --directory=/tmp
    mv /tmp/caddy /usr/local/bin
fi

echo "Setting Caddy permissions..."
chmod 755 /usr/local/bin/caddy

echo "Setting Caddy to run on startup..."
chmod 644 /etc/systemd/system/caddy.service
systemctl enable caddy

echo "Giving Caddy  access to ports <1024..."
setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

echo "Cloning projects..."
if git --git-dir="$repo/.git" rev-parse; then
    git --git-dir="$repo/.git" fetch
    git --git-dir="$repo/.git" checkout origin/master
else
    mkdir -p "$repo" "$served"
    chown -R www-data:www-data "$repo"
    chown -R www-data:www-data "$served"
    ssh-keyscan github.com >> ~/.ssh/known_hosts # we may have git+ssh submodules
    git clone --recursive "https://github.com/OJFord/$repo_name" "$repo"
fi
git --git-dir="$repo/.git" checkout-index -a -f --prefix="$served/"

echo "Setting Caddy to serve projects..."
mkdir -p /etc/caddy
ln -sf "$served/Caddyfile" /etc/caddy/Caddyfile

echo "Setting permissions on Caddy data..."
chown -R root:www-data /etc/caddy
chmod 444 /etc/caddy/Caddyfile

echo "Setting permissions on Caddy SSL data..."
mkdir -p /etc/ssl/caddy
chown -R www-data:root /etc/ssl/caddy
chmod 0770 /etc/ssl/caddy

echo "Changing misc. Caddy-recommended settings..."
ulimit -n 8192

echo "Starting Caddy server..."
systemctl daemon-reload
systemctl restart caddy
