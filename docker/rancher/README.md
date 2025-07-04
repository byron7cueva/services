docker run -d --restart=unless-stopped \
  --name rancher \
  -p 8080:80 -p 8443:443 \
  --privileged \
  rancher/rancher:v2.11.3