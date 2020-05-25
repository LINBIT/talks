#!/bin/bash

# show that mysql is running in a suboptimal location:
kubectl get pods -o wide
kubectl exec -it linstor-op-cs-controller-0 -- linstor volume list

# first, undo what we did before
kubectl delete -f mysql.yaml

# deploy stork + scheduler
less stork-deployment.yaml
kubectl apply -f stork-deployment.yaml
kubectl get pods -A

less stork-scheduler.yaml
kubectl apply -f stork-scheduler.yaml
kubectl get pods -A

vim mysql.yaml
# diff --git a/mysql.yaml b/mysql.yaml
# index b209972..3a93a2b 100644
# --- a/mysql.yaml
# +++ b/mysql.yaml
# @@ -24,6 +24,7 @@ spec:
#        labels:
#          app: mysql
#      spec:
# +      schedulerName: stork
#        containers:
#        - image: mysql:8.0
#          name: mysql

kubectl apply -f mysql.yaml
kubectl get pods -o wide
