DBX_CONTAINER_MANAGER="docker" DISTROBOX_BACKEND="docker" distrobox create \
  --name ia-ubuntu \
  --image ubuntu:24.04 \
  --init \
  --yes \
  --additional-flags "--gpus all" \
  -H /mnt/volumes/distrobox/ia-ubuntu