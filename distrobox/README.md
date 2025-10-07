DBX_CONTAINER_MANAGER="docker" DISTROBOX_BACKEND="docker" distrobox create \
 --name ia-ubuntu \
 --image ubuntu:24.04 \
 --init \
 --yes \
 --additional-flags "--gpus all" \
 -H /mnt/volumes/distrobox/ia-ubuntu

## Install Podman

```bash
sudo apt-get update
sudo apt-get -y install podman
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
  graphroot = "/mnt/containers/podman/root/graphroot"
  runroot = "/mnt/containers/podman/root/runroot"
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
  graphroot = "/mnt/containers/podman/bcueva/graphroot"
  runroot = "/mnt/containers/podman/bcueva/runroot"
```

## Instalar distrobox

curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh

distrobox create -i quay.io/toolbx/ubuntu-toolbox:24.04 -n kruger -H /mnt/volumes/distrobox/kruger

### Frontend container

distrobox create -i docker.io/library/archlinux:latest -n arch-web -H /mnt/containers/distrobox/arch-web

distrobox enter arch-web

distrobox create -i alpine:latest -n alpine-go -H /mnt/containers/distrobox/alpine-go

sudo apk add go git build-base

distrobox create -n arch-python -i docker.io/library/archlinux:latest -H /mnt/containers/distrobox/arch-python \
 --init \
 --yes

Instala herramientas básicas

sudo pacman -S --noconfirm \
 python \
 python-pip \
 python-setuptools \
 python-wheel \
 python-virtualenv \
 git \
 base-devel \
 jupyter-notebook

sudo pacman -S --noconfirm gcc-fortran blas lapack

Crea un entorno virtual
Esto aísla tus dependencias de sistema.

python -m venv ~/.venv/ia
source ~/.venv/ia/bin/activate

python -m pip install --upgrade pip setuptools wheel

pip install --upgrade pip
pip install numpy pandas scipy scikit-learn matplotlib seaborn jupyter
pip install torch torchvision torchaudio

distrobox rm --force kruger

Agrega en .vscode/settings.json en el proyecto para abrirlo con vscode

"terminal.integrated.profiles.linux": {
"distrobox": {
"path": "/usr/bin/env",
"args": ["distrobox", "enter", "nombre-del-contenedor"]
}
},
"terminal.integrated.defaultProfile.linux": "distrobox"
