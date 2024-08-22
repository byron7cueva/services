## Documentation

https://postgres-operator.readthedocs.io/en/latest/
cre
https://github.com/zalando/postgres-operator/blob/master/docs/quickstart.md

## Add repository

```shell
export ZALANDO_BASE=https://raw.githubusercontent.com/zalando/postgres-operator
helm repo add zalando-pg $ZALANDO_BASE/master/charts/postgres-operator/
helm repo add zalando-ui $ZALANDO_BASE/master/charts/postgres-operator-ui/
helm repo update
```

## Install operator

```shell
helm upgrade -i \
  --create-namespace -n zalando-pg-operator \
  --set env.TZ="America/New_York" \
  -f values.yaml \
  pg-operator \
  zalando-pg/postgres-operator
```

## Uninstall operator

```shell
helm uninstall pg-operator -n zalando-pg-operator
```

## Install UI

```shell
helm upgrade -i \
  --create-namespace -n zalando-pg-operator \
  pg-operator-ui \
  zalando-ui/postgres-operator-ui
```

## Uninstall ui

```shell
helm uninstall pg-operator-ui -n zalando-pg-operator
```

## Open UI

```shell
kubectl port-forward svc/pg-operator-ui-postgres-operator-ui 8081:80 -n zalando-pg-operator
```

## Cluster Postgresql

### Create cluster

```shell
# Create
kubectl create -f cluster.yaml

oc adm policy add-scc-to-user anyuid -z pg-operator-postgres-operator  -n postgres
oc adm policy add-scc-to-user anyuid -z postgres-pod  -n postgres

# check the deployed cluster
kubectl get postgresql -n postgres

# check created database pods
kubectl get pods -l application=spilo -L spilo-role -n postgres


      serviceAccount: pg-operator-postgres-operator


# check created service resources
kubectl get svc -l application=spilo -L spilo-role -n postgres

kubectl get secret -n postgres
oc get secret postgres.postgres-cluster.credentials.postgresql.acid.zalan.do -n postgres -o 'jsonpath={.data.password}' |  base64 -d
```

### Delete cluster

```shell
kubectl delete -f cluster.yaml
```
