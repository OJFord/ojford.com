#!/bin/sh

# Addons for the server (urlencoded query string)
caddy_features=""

repo_name="ojford.com"
repo="/var/git/$repo_name"
served="/var/www/$repo_name"

if ! hash caddy 2>/dev/null; then
    wget "https://caddyserver.com/download/build?os=linux&arch=amd64&features=$caddy_features" -O caddy.gz
    tar -xvf caddy.gz --directory=caddy
    mv caddy/caddy /usr/local/bin
    chmod 755 /usr/local/bin/caddy
    mv caddy/init/linux-systemd/caddy.service /etc/systemd/system
    chmod 744 /etc/systemd/system/caddy.service
    rm -r caddy
    
    # Non-root access to ports <1024
    setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

    mkdir -p /etc/caddy
    echo 'import $served/Caddyfile' >> /etc/caddy/Caddyfile
    chown -R root:www-data /etc/caddy
    chmod 444 /etc/caddy/Caddyfile

    mkdir -p /etc/ssl/caddy
    chown -R www-data:root /etc/ssl/caddy
    chmod 0770 /etc/ssl/caddy

    # Squashes Caddy warning
    ulimit -n 8192
fi

if [ -d "$repo" ]; then
    mkdir -p "$repo" "$served" && cd "$repo"
    git init --bare

    echo "#!/bin/sh" > hooks/post-receive
    echo "git --work-tree=$served --git-dir=$repo checkout -f" >> hooks/post-receive
    echo "chown -R www-data:www-data $served" >> hooks/post-receive
    echo "chmod -R 555 $served" >> hooks/post-receive
    chmod +x hooks/post-receive
fi

systemctl enable caddy
