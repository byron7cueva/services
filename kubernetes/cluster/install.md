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

virt-install \
--name k3s-master \
--memory 2048 \
--vcpus 2 \
--disk pool=bc_pool,size=20,format=qcow2 \
--os-variant generic \
--network bridge=br0 \
--cdrom ~/isos/alpine-virt-3.20.0-x86_64.iso \
--graphics none
