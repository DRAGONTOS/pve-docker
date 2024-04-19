# pve-docker
For running a proxmox server in a Docker container!

## Info
You might want to change the hostname in docker-compose.yml to something you like, and for Socat
You can change the './socat/data/socat.sh' and ips/ports you want to passtthrough. AND DONT FORGET TO DO THAT
TOO IN THE DOCKER-COMPOSE.YML!!

## Network setup
You can set up the network with this:
```bash
sudo docker network create --ipam-driver default --subnet 192.168.12.0/24 netvm
```

## Building the images
We first need to build the images to do this:
```bash
sudo docker compose build
```
And you will need to do that too for Socat. Just run this:
```bash
cd socat && sudo docker compose build && cd ..
```

## Testing
Now that they are built you can run this:
```bash
sudo docker compose up
```
And to test Socat, just run this:
```bash
cd socat && sudo docker compose up && cd ..
```
If everything seems fine (no errors), then you can run them with -d!

# Contributors
- DRAGONTOS


