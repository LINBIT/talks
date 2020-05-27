#!/bin/bash

# show that mysql is running in a suboptimal location:
kubectl get pods -o wide
kubectl exec -it piraeus-op-cs-controller-0 -- linstor volume list

# first, undo what we did before
kubectl delete -f mysql.yaml

# deploy stork + scheduler
kubectl apply -f stork-deployment.yaml
less stork-deployment.yaml
watch kubectl get pods -A

kubectl apply -f stork-scheduler.yaml
less stork-scheduler.yaml
watch kubectl get pods -A

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

kubectl exec -it piraeus-op-cs-controller-0 -- linstor volume list

kubectl apply -f linstor-pvc.yaml
kubectl apply -f mysql.yaml
watch kubectl get pods -o wide
