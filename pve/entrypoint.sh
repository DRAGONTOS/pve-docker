#!/bin/bash
set -eo pipefail
shopt -s nullglob
ADMIN_PASSWORD="nyaowo"

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
	if [ -z "$ADMIN_PASSWORD" ]; then
		pve_error $'Password option is not specified\n\tYou need to specify an ADMIN_PASSWORD'
	fi
}

docker_setup_pve() {
    #Set pve user
    echo "root:$ADMIN_PASSWORD"|chpasswd
}

RELAY_HOST=${RELAY_HOST:-ext.home.local}
sed -i "s/RELAY_HOST/$RELAY_HOST/" /etc/postfix/main.cf
PVE_ENTERPRISE=${PVE_ENTERPRISE:-no}
rm -f /etc/apt/sources.list.d/pve-enterprise.list

docker_verify_minimum_env

mkdir -p /var/lib/dhcp
apt update && apt install ifupdown2 -y || true
echo 'rander:12345' | chpasswd
mkdir -p /run/sshd
chmod 755 /run/sshd
/usr/sbin/sshd

systemctl enable networking


#ip route add default via 192.168.0.2/20
#bridge
#brctl addbr vmbr0 eth1 
#brctl addif vmbr0 eth1 
#ip link set vmbr0 up

# Start api first in background
#echo -n "Starting Proxmox VE API..."
#/usr/lib/x86_64-linux-gnu/proxmox-backup/proxmox-backup-api &
#while true; do
#    if [ ! -f /run/proxmox-backup/api.pid ]; then
#        echo -n "..."
#        sleep 3
#    else
#        break
#    fi
#done
#echo "OK"

docker_setup_pve

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
    sleep 60  # Adjust the sleep interval as needed
done

#exec gosu backup /usr/lib/x86_64-linux-gnu/proxmox-backup/proxmox-backup-proxy "$@"
