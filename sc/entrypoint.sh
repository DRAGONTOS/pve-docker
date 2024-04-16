#!/bin/bash
set -eo pipefail
shopt -s nullglob
ADMIN_PASSWORD="nyaowo"

# Verify that the minimally required password settings are set for new databases.
docker_setup_pve() {
    #Set pve user
    echo "root:$ADMIN_PASSWORD"|chpasswd
}


mkdir -p /var/lib/dhcp
#sudo apt install ifupdown2 -y || true
echo 'rander:12345' | chpasswd
mkdir -p /run/sshd
sudo chmod 755 /run/sshd
/usr/sbin/sshd

sudo socat -dd  TCP-LISTEN:8006,fork,reuseaddr,keepalive,keepidle=60,keepintvl=60 TCP:192.168.12.2:8006,keepalive,keepidle=60,keepintvl=60 && \
sudo socat -dd TCP-LISTEN:2222,fork,reuseaddr,keepalive,keepidle=60,keepintvl=60 TCP:192.168.12.2:22,keepalive,keepidle=60,keepintvl=60


#systemctl enable networking


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

echo "Running SOCAT..."
exec "$@"

while true; do
    # Your commands or checks here
    sleep 60  # Adjust the sleep interval as needed
done

#exec gosu backup /usr/lib/x86_64-linux-gnu/proxmox-backup/proxmox-backup-proxy "$@"
