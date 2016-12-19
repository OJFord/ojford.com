## Setup
Deployment is mostly via Terraform, the remaining first-run manual steps are:
- `ssh server "erb caddy.service.erb > /etc/systemd/system/caddy.service"`
- `ssh server "bash -s" < bootstrap.sh`
