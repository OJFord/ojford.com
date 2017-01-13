#!/bin/bash
set -e

# Addons for the server (space separated)
caddy_features="git cloudflare"
repo_name="ojford.com"
repo="/var/git/$repo_name"
served="/var/www/$repo_name"

install_caddy(){
    echo "Installing Caddy with: $caddy_features..."
    build_params="os=linux&arch=amd64&features=${caddy_features// /%2C}"
    curl "https://caddyserver.com/download/build?$build_params" -o /tmp/caddy.gz
    tar -xvf /tmp/caddy.gz --directory=/tmp
    mv /tmp/caddy /usr/local/bin
}

if ! hash caddy 2>/dev/null; then
    install_caddy
fi

expect_plugins=$(echo "$caddy_features" | wc -w)
actual_plugins=$(caddy -plugins | grep -E "${caddy_features// /|}")
if [ "$actual_plugins" == "$expect_plugins" ]; then
    install_caddy
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
    chown www-data:www-data /var/www
    chown -R www-data:www-data "$repo"
    chown -R www-data:www-data "$served"
    ssh-keyscan github.com >> ~/.ssh/known_hosts # we may have git+ssh submodules
    git clone --recursive "https://github.com/OJFord/$repo_name" "$repo"
    chown -R root:www-data .project_git_template/hooks
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

echo "Allowing Caddy to restart itself..."
echo "%www-data ALL= NOPASSWD: /bin/systemctl reload caddy" > /etc/sudoers.d/caddy-reload

echo "Allowing Caddy to run Docker..."
usermod --append --groups=docker www-data

echo "Changing misc. Caddy-recommended settings..."
ulimit -n 8192

echo "Starting Caddy server..."
systemctl daemon-reload
systemctl restart caddy
