#!/bin/bash
set -eo pipefail
shopt -s nullglob
ADMIN_PASSWORD="nyaowo"

# Verify that the minimally required password settings are set for new databases.
echo "root:$ADMIN_PASSWORD"|chpasswd
mkdir -p /var/lib/dhcp
/bin/bash /root/socat.sh &


echo "Running SOCAT..."
exec "$@"

while true; do
    # Your commands or checks here
    sleep 60  # Adjust the sleep interval as needed
done
