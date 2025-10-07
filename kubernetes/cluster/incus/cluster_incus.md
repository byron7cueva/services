## Instalar incus

Ref: https://linuxcontainers.org/incus/docs/main/installing/
Ref: https://github.com/zabbly/incus

```bash
sudo apt update
sudo apt install incus incus-client
sudo apt install qemu-system

# Agregar al grupo
sudo usermod -aG incus-admin $USER
newgrp incus-admin
getent group incus-admin
sudo usermod -aG incus $USER

# Desabilitar para que no inicie al iniciar el host
sudo systemctl disable incus
sudo systemctl disable incus.socket

# Inicializar incus
incus admin init --minimal
# incus init

# Crear un nuevo storage
incus storage create bg_storage dir source=/mnt/containers/incus
```

Editar el profile por defecto

```bash
incus profile edit default
```

Se abrira un editor de texto (como nano o vi). Busca la seccion devices: y cambia la linea pool: default a pool: <nuevo_pool>.

```yaml
config: {}
description: Default Incus profile
devices:
  eth0:
    name: eth0
    network: lxdbr0
    type: nic
  root:
    path: /
    pool: <nuevo_pool> # Cambia 'default' por el nombre de tu nuevo pool
    type: disk
name: default
used_by:
- /1.0/instances/mi-webserver
```

Guardar el archivo y cerrar

Eliminar el storage pool antiguo

```bash
incus storage delete default
```


## Preparar nodos

Crear nodos

```bash
# CON UBUNTU
incus launch images:ubuntu/22.04 k3s-master --vm -c limits.cpu=2 -c limits.memory=2GiB
incus launch images:ubuntu/22.04 k3s-worker-1 --vm -c limits.cpu=4 -c limits.memory=6GiB
incus launch images:ubuntu/22.04 k3s-worker-2 --vm -c limits.cpu=4 -c limits.memory=6GiB
# Instalar dependencias en los nodos
for node in k3s-master k3s-worker-1 k3s-worker-2; do
  incus exec $node -- bash -c "apt update && apt install -y curl iptables iproute2"
done

# CON APLINE
incus launch images:alpine/3.20 k3s-master --vm -c security.secureboot=false -c limits.cpu=2 -c limits.memory=2GiB
incus launch images:alpine/3.20 k3s-worker-1 --vm -c security.secureboot=false -c limits.cpu=4 -c limits.memory=6GiB
incus launch images:alpine/3.20 k3s-worker-2 --vm -c security.secureboot=false -c limits.cpu=4 -c limits.memory=6GiB
# Instalar dependencias por cada nodo
incus shell k3s-master
apk update
apk add curl iptables ip6tables eudev bash containerd openrc
apk add vim htop bind-tools
```

## Instalar cluster

Instalar el nodo master

```bash
incus exec k3s-master -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--disable traefik' sh -"

# Verificar que este funcionando
incus exec k3s-master -- kubectl get nodes

```

Obtener el token del master

```bash
incus exec k3s-master -- cat /var/lib/rancher/k3s/server/node-token
```

Obtener la IP del Master

```bash
incus list k3s-master
```

Instalar k3s en los workers

Sustituir la IP del master y el token

```bash
TOKEN=MI_TOKEN_AQUI
IP=IP_DEL_MASTER

for node in k3s-worker-1 k3s-worker-2; do
  incus exec $node -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=https://$IP:6443 K3S_TOKEN=$TOKEN sh -"
done
```

Validar que los nodos esten listos

```bash
incus exec k3s-master -- kubectl get nodes -o wide
```

## Instalar Nginx Controller

```bash
# Instalar
incus exec k3s-master -- kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml

# Esperar que los pods esten listos
incus exec k3s-master -- kubectl get pods -n ingress-nginx --watch
```

## Exportar archivo kubeconfig

Copiar kubeconfig desde la maquina virtual

```bash
incus file pull k3s-master/etc/rancher/k3s/k3s.yaml ~/.kube/k3s.yaml
# Actualizar la ip por la del nodo master
```

## Aumentar recursos

Ver recursos limite asignados

```bash
incus config show k3s-master --expanded | grep limits
```

Parar nodo

```bash
incus stop k3s-master
```

Asignar recursos

```bash
incus config set k3s-master limits.memory 2GiB
incus config set k3s-master limits.cpu 2
```

Iniciar nodo

```bash
incus start k3s-master
```

## Desinstalar cluster

```bash
# Desinstalar k3s
incus exec k3s-master -- /usr/local/bin/k3s-uninstall.sh
incus exec k3s-worker-1 -- /usr/local/bin/k3s-agent-uninstall.sh
incus exec k3s-worker-2 -- /usr/local/bin/k3s-agent-uninstall.sh

# Parar nodos
incus stop k3s-master
incus stop k3s-worker-1
incus stop k3s-worker-2

# Eliminar nodos
incus delete k3s-master
incus delete k3s-worker-1
incus delete k3s-worker-2
```
