## Laravel + Kubernetes

Crear namespaces

- kubectl create namespace application-services
- kubectl create namespace application-storage

Instalar bases de datos

helm repo add bitnami https://charts.bitnami.com/bitnami

helm install posgresql bitnami/postgresql --namespace application-storage

Despues de la ejecucion del comando debe poder ver en consola un texto similar,
siguiendo los pasos especificados podremos obtener la informacion de usuario y contraseña

NAME: posgresql
LAST DEPLOYED: Thu Mar 31 12:40:22 2022
NAMESPACE: application-storage
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: postgresql
CHART VERSION: 11.0.6
APP VERSION: 14.1.0

** Please be patient while the chart is being deployed **

PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:

    posgresql-postgresql.application-storage.svc.cluster.local - Read/Write connection

To get the password for "postgres" run:

    export POSTGRES_PASSWORD=$(kubectl get secret --namespace application-storage posgresql-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode)

To connect to your database run the following command:

    kubectl run posgresql-postgresql-client --rm --tty -i --restart='Never' --namespace application-storage --image docker.io/bitnami/postgresql:14.1.0-debian-10-r80 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host posgresql-postgresql -U postgres -d postgres -p 5432

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace application-storage svc/posgresql-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432

helm install redis bitnami/redis --namespace application-storage

NAME: redis
LAST DEPLOYED: Thu Mar 31 13:28:49 2022
NAMESPACE: application-storage
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: redis
CHART VERSION: 16.4.0
APP VERSION: 6.2.6

** Please be patient while the chart is being deployed **

Redis&trade; can be accessed on the following DNS names from within your cluster:

    redis-master.application-storage.svc.cluster.local for read/write operations (port 6379)
    redis-replicas.application-storage.svc.cluster.local for read-only operations (port 6379)

To get your password run:

    export REDIS_PASSWORD=$(kubectl get secret --namespace application-storage redis -o jsonpath="{.data.redis-password}" | base64 --decode)

To connect to your Redis&trade; server:

1. Run a Redis&trade; pod that you can use as a client:

   kubectl run --namespace application-storage redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:6.2.6-debian-10-r120 --command -- sleep infinity

   Use the following command to attach to the pod:

   kubectl exec --tty -i redis-client \
   --namespace application-storage -- bash

2. Connect using the Redis&trade; CLI:
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-master
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-replicas

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace application-storage svc/redis-master : &
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p
