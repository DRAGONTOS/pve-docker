#!/bin/bash
set -eo pipefail
shopt -s nullglob
ADMIN_PASSWORD="nyaowo"
USER_PASSWORD="nyaowo"

# logging functions
pve_log() {
	local type="$1"; shift
	printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-3339=seconds)" "$type" "$*"
}
pve_note() {
	pve_log Note "$@"
}
pve_warn() {
	pve_log Warn "$@" >&2
}
pve_error() {
	pve_log ERROR "$@" >&2
	exit 1
}

# Verify that the minimally required password settings are set for new databases.
docker_verify_minimum_env() {
  if [ -z "$ADMIN_PASSWORD" ] && [ "$USER_PASSWORD" ]; then
		pve_error $'Password option is not specified\n\tYou need to specify an ADMIN/USER_PASSWORD'
	fi
}

networking_misc() {
mkdir /run/sshd && chmod 0755 /run/sshd && /usr/sbin/sshd &
systemctl start networking && systemctl start isc-dhcp-server &
}


docker_setup_pve() {
    #Set root user
    echo "root:$ADMIN_PASSWORD"|chpasswd
    #Set user
    echo "pve:$USER_PASSWORD"|chpasswd
}

RELAY_HOST=${RELAY_HOST:-ext.home.local}
sed -i "s/RELAY_HOST/$RELAY_HOST/" /etc/postfix/main.cf
PVE_ENTERPRISE=${PVE_ENTERPRISE:-no}
rm -f /etc/apt/sources.list.d/pve-enterprise.list

# functions
docker_verify_minimum_env
docker_setup_pve
sleep 10 && networking_misc &

if [ ! -d /var/log/pveproxy ]; then
    mkdir -p /var/log/pveproxy
    chmod 777 /var/log/pveproxy
fi

if [ -n "$ENABLE_PVE_FIREWALL" -a "$ENABLE_PVE_FIREWALL" == "no" ]; then
    systemctl mask pve-firewall.service
fi

echo "Running PVE..."
exec "$@"

while true; do
    # Your commands or checks here
    sleep 1m  # Adjust the sleep interval as needed
done
