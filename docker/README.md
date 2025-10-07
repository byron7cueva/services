## Install docker

### Add repository

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Install

```bash
sudo apt update -y

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Running docker without sudo

```bash
sudo usermod -aG docker $USER

newgrp docker
```

### Change path docker

Add file /etc/docker/daemon.json

```json
{
  "data-root": "/mnt/volumes/docker"
}
```

### Reiniciar los servicios

```bash
# Disable
sudo systemctl disable docker
sudo systemctl disable docker.socket

sudo systemctl restart docker
```


## Install Podman

```bash
sudo apt-get update
sudo apt -y  install podman uidmap slirp4netns
sudo systemctl disable podman
sudo systemctl disable podman.socket
```

Cambiar la ruta global por defecto

```bash
sudo nano /etc/containers/storage.conf
```

Agregar las lineas

```conf
[storage]
  driver = "overlay"
  graphroot = "/mnt/volumes/podman/root/graphroot"
  runroot = "/mnt/volumes/podman/root/runroot"
```

Cambiar la ruta de usuario

```bash
mkdir -p ~/.config/containers
nano ~/.config/containers/storage.conf
```

Agregar las lineas

```conf
[storage]
  driver = "overlay"
  graphroot = "/mnt/volumes/podman/bcueva/graphroot"
  runroot = "/mnt/volumes/podman/bcueva/runroot"
```

# Run services

docker network create "devnet"
docker compose -f postgres.yml up -d
docker compose -f keycloak.yml up -d
docker compose -f nginx.yml up -d

distrobox create -i quay.io/toolbx/ubuntu-toolbox:24.04 -n kruger -H /mnt/volumes/distrobox/kruger

distrobox create -i quay.io/toolbx/arch-toolbox:latest -n frontend -H /mnt/volumes/distrobox/frontend

distrobox rm --force kruger

Agrega en .vscode/settings.json en el proyecto para abrirlo con vscode

"terminal.integrated.profiles.linux": {
  "distrobox": {
    "path": "/usr/bin/env",
    "args": ["distrobox", "enter", "nombre-del-contenedor"]
  }
},
"terminal.integrated.defaultProfile.linux": "distrobox"
