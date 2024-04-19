# pve-docker
For running a proxmox server in a Docker container!

## Info
You might want to change the hostname in docker-compose.yml to something you like, and for Socat
You can change the './socat/data/socat.sh' and ips/ports you want to passtthrough. AND DONT FORGET TO DO THAT
TOO IN THE DOCKER-COMPOSE.YML!!

## Building the images
We first need to build the images to do this:
```bash
sudo docker compose build
```
And you will need to do that too for Socat. Just run this:
```bash
sudo docker compose --project-directory socat build
```

## Testing
Now that they are built you can run this:
```bash
docker compose up
```
And to test Socat, just run this:
```bash
docker compose --project-directory socat up
```
If everything seems fine (no errors), then you can run them with -d!

# Contributors
- DRAGONTOS


