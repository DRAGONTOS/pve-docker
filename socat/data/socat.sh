socat -dd  TCP-LISTEN:8006,fork,reuseaddr,keepalive,keepidle=60,keepintvl=60 TCP:192.168.12.2:8006,keepalive,keepidle=60,keepintvl=60 &
socat -dd TCP-LISTEN:2222,fork,reuseaddr,keepalive,keepidle=60,keepintvl=60 TCP:192.168.12.2:22,keepalive,keepidle=60,keepintvl=60 &

