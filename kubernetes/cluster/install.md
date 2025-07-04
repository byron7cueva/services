# Install Cluster

## Install kvm

´´´bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
´´´

## Create a new storage Pool

Create a new directory.

´´´bash
mkdir /media/bcueva/volumes/kvm
sudo chmod 755 /media/bcueva/volumes/kvm
sudo chown libvirt-qemu:kvm /media/bcueva/volumes/kvm
sudo chown libvirt-qemu:kvm /media/bcueva/volumes/iso
sudo setfacl -m u:libvirt-qemu:x /media/bcueva
sudo setfacl -m u:libvirt-qemu:x /media/bcueva/volumes
´´´

Define new Storage Pool

´´´bash
sudo virsh pool-define-as --name bc_pool --type dir --target /media/bcueva/volumes/kvm
´´´
Build Pool

´´´bash
sudo virsh pool-build bc_pool
´´´

Start Pool

´´´bash
sudo virsh pool-start bc_pool
sudo virsh pool-autostart bc_pool
´´´

Validation the new Pool

´´´bash
sudo virsh pool-list --all
sudo virsh pool-info bc_pool
´´´

## Configuracion de Red

Asegurar que el host usa un bridge en lugar de su interfaz física (ej. eth0 o enp3s0):

Edita o crea un archivo como /etc/netplan/01-br0.yaml

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp6s0:
      dhcp4: no
  bridges:
    br0:
      interfaces: [enp6s0]
      dhcp4: yes
```

Aplicar cambios

```bash
sudo netplan apply

sudo systemctl restart systemd-networkd.service
```

Elimina el NAT por defecto y crea un nuevo "network" que use br0:

```bash
sudo virsh net-destroy default
sudo virsh net-undefine default

cat <<EOF | sudo tee /etc/libvirt/qemu/networks/hostbridge.xml
<network>
  <name>hostbridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

sudo virsh net-define /etc/libvirt/qemu/networks/hostbridge.xml
sudo virsh net-start hostbridge
sudo virsh net-autostart hostbridge
```

## Crear maquinas virtuales

virt-install \
--name k3s-master \
--memory 2048 \
--vcpus 2 \
--disk pool=bc_pool,size=20 \
--os-variant generic \
--network network=hostbridge,model=virtio \
--cdrom /media/bcueva/volumes/iso/alpine-virt-3.22.0-x86_64.iso \
--graphics none


virt-install \
--name k3s-worker1 \
--memory 6144 \
--vcpus 4 \
--disk pool=bc_pool,size=60 \
--os-variant generic \
--network network=hostbridge,model=virtio \
--cdrom /media/bcueva/volumes/iso/alpine-virt-3.22.0-x86_64.iso \
--graphics none


virt-install \
--name k3s-worker2 \
--memory 6144 \
--vcpus 4 \
--disk pool=bc_pool,size=60 \
--os-variant generic \
--network network=hostbridge,model=virtio \
--cdrom /media/bcueva/volumes/iso/alpine-virt-3.22.0-x86_64.iso \
--graphics none

## Instalar
Login root
setup-alpine

## Configurar
apk update && apk add curl

### Master
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --write-kubeconfig-mode 644" sh -

cat /var/lib/rancher/k3s/server/node-token

### Worker

Agregar host k3s-master en /etc/hosts

curl -sfL https://get.k3s.io | K3S_URL=https://k3s-master:6443 \
K3S_TOKEN=K10cfb83c5d0cedf395e13db94402e4f0d3bb3c8c1d7a7d40d0d588e9c7b3d6d2bf::server:aea58decae4c82f2c5aec520bbedfb1c sh -

## Labels

kubectl label node k3s-worker1 node-role.kubernetes.io/worker=worker
kubectl label node k3s-worker2 node-role.kubernetes.io/worker=worker
kubectl taint node k3s-master node-role.kubernetes.io/master=true:NoSchedule

## Habilitar ssh con root

Abrir el archivo de configuración

vi /etc/ssh/sshd_config

Asegúrate de tener estas líneas (reemplace o descomente las existentes):

PermitRootLogin yes
PasswordAuthentication yes

También puedes añadir una línea para restringir acceso a un solo usuario:

AllowUsers root

Guarda el archivo y reinicia el servicio SSH:

service sshd restart


scp root@192.168.0.103:/etc/rancher/k3s/k3s.yaml ~/.kube/config
sed -i "s/127.0.0.1/192.168.0.103/" ~/.kube/config

## Configurar LoadBalancer MetalLB

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.2/config/manifests/metallb-native.yaml


kubectl apply -f ./metallb.yml

kubectl logs -n metallb-system -l app=metallb,component=speaker
kubectl delete pods -n metallb-system -l app=metallb,component=speaker
kubectl get pods -A -o wide


## Instalar Ingress Controller Nginx

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.3/deploy/static/provider/baremetal/deploy.yaml

kubectl get pods -n ingress-nginx


## Run demo

kubectl create namespace apps

kubectl get svc demo -n default -o jsonpath='{.spec.clusterIP}'

kubectl create namespace utils
kubectl get pods -n utils

kubectl exec -n utils -it red -- ping demo.default.svc.cluster.local




kubectl exec -n utils -it red -- nslookup demo.apps.svc.cluster.local

kubectl exec -n utils -it red -- nc -vz demo.apps.svc.cluster.local 80


Rancher

virt-install \
--name rancher \
--ram 4096 --vcpus 2 \
--disk pool=bc_pool,size=20 \
--network bridge=virbr0,model=virtio \
--os-variant generic \
--cdrom /media/bcueva/volumes/iso/alpine-virt-3.22.0-x86_64.iso \
--graphics none


apk update
apk add chrony tzdata

rc-update add chronyd default
rc-service chronyd start

chronyc tracking


apk add curl
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --cluster-init" sh -

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
sh ./get_helm.sh

helm version

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml


helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.18.0 \
  --set installCRDs=true


helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create namespace cattle-system

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.local \
  --set ingress.tls.source=secret \
  --set bootstrapPassword="admin"

kubectl port-forward -n cattle-system svc/rancher 8443:443 --address 0.0.0.0
