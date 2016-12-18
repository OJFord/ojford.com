#!/bin/bash
set -e

# Addons for the server (space separated)
caddy_features="git cloudflare"

repo_name="ojford.com"
repo="/var/git/$repo_name"
served="/var/www/$repo_name"

if ! hash caddy 2>/dev/null; then
    build_params="os=linux&arch=amd64&features=${caddy_features// /%2C}"
    wget "https://caddyserver.com/download/build?$build_params" -O caddy.gz
    tar -xvf caddy.gz --directory=/tmp
    mv /tmp/caddy /usr/local/bin
    chmod 755 /usr/local/bin/caddy
    mv /tmp/init/linux-systemd/caddy.service /etc/systemd/system
    chmod 644 /etc/systemd/system/caddy.service

    # Non-root access to ports <1024
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

    mkdir -p /etc/caddy
    # Dummy Caddyfile that serves only to clone the repo with the real one
    cat << EOF > /etc/caddy/Caddyfile
ojford.com
tls off
git {
    repo https://github.com/OJFord/$repo_name
    path $repo
    hook /gh_webhook $GITHUB_WEBHOOK_KEY
    then git --git-dir=$repo/.git checkout-index -a -f --prefix=$served/
    then ln -sf $served/Caddyfile /etc/caddy/Caddyfile 
}
EOF
    chown -R root:www-data /etc/caddy
    chmod 444 /etc/caddy/Caddyfile
    mkdir -p "$repo" "$served"

    mkdir -p /etc/ssl/caddy
    chown -R www-data:root /etc/ssl/caddy
    chmod 0770 /etc/ssl/caddy

    # Squashes Caddy warning
    ulimit -n 8192
fi

systemctl enable caddy
