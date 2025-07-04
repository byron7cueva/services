# Nexus

## Get password

```sh
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nexus.key \
  -out nexus.crt \
  -config nexus-openssl.cnf

openssl x509 -in nexus.crt -text | grep -A1 "Subject Alternative Name"

docker compose -f nexus.yml up -d
sudo docker exec -it nexus cat /nexus-data/admin.password
```
scp nexus.crt user@node:/tmp/
apk update
apk add ca-certificates

mkdir -p /usr/local/share/ca-certificates
cp /tmp/nexus.crt /usr/local/share/ca-certificates/nexus.crt
ls -l /usr/local/share/ca-certificates/nexus.crt
head -n 1 /usr/local/share/ca-certificates/nexus.crt


update-ca-certificates

openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /usr/local/share/ca-certificates/nexus.crt


vi /etc/rancher/k3s/registries.yaml

```yaml
mirrors:
  "nexus.local:5001":
    endpoint:
      - "https://nexus.local:5001"

configs:
  "nexus.local:5001":
    tls:
      ca_file: "/usr/local/share/ca-certificates/nexus.crt"
```

rc-service k3s restart
rc-service k3s-agent restart


kubectl create secret docker-registry sct-docker-nexus-reg \
  --docker-server=nexus.local:5001 \
  --docker-username=docker \
  --docker-password=docker \
  --docker-email=docker@local.com



sudo mkdir -p /etc/docker/certs.d/nexus.local:5001
sudo cp nexus.crt /etc/docker/certs.d/nexus.local:5001/ca.crt
sudo systemctl restart docker

docker login nexus.local:5001