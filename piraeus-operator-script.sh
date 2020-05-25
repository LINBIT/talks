#!/bin/bash

kubectl get nodes

for h in centos-7-k8s-10{1..4}.test; do kubectl label node $h linstor.linbit.com/piraeus-node=true; done

# run from piraeus-operator v0.3.0
helm install linstor-etcd ./charts/pv-hostpath --set "nodes={centos-7-k8s-101.test,centos-7-k8s-102.test,centos-7-k8s-103.test}"
kubectl get pv

helm install piraeus-op ./charts/piraeus --set operator.nodeSet.kernelModImage=quay.io/piraeusdatastore/drbd9-centos7:v9.0.22
watch kubectl get pod -o wide

kubectl exec piraeus-op-cs-controller-0 -- linstor node list

kubectl exec piraeus-op-cs-controller-0 -- linstor storage-pool list

kubectl exec piraeus-op-cs-controller-0 -- linstor physical-storage list

kubectl exec piraeus-op-cs-controller-0 -- linstor physical-storage create-device-pool LVMTHIN centos-7-k8s-101.test /dev/sda --pool-name lvm-thin --storage-pool lvm-thin
kubectl exec piraeus-op-cs-controller-0 -- linstor physical-storage create-device-pool LVMTHIN centos-7-k8s-102.test /dev/sda --pool-name lvm-thin --storage-pool lvm-thin

kubectl exec piraeus-op-cs-controller-0 -- linstor storage-pool list

# run from cncf-webinar
cat linstor-storage-class.yaml
kubectl apply -f linstor-storage-class.yaml
cat linstor-pvc.yaml
kubectl apply -f linstor-pvc.yaml

kubectl get persistentvolumes
kubectl exec piraeus-op-cs-controller-0 -- linstor volume list

# demo: mysql running on linstor storage
cat mysql.yaml
kubectl apply -f mysql.yaml
watch kubectl get pod
kubectl logs -l app=mysql --follow

kubectl run -it --rm --image=mysql:8.0 --restart=Never mysql-client -- mysql -h mysql -ppassword
# in mysql, show that is working, something like
# SELECT VERSION();

cat employees.sql | kubectl run -i --rm --image=mysql:8.0 --restart=Never mysql-client -- mysql -h mysql -ppassword -t
# takes about 10 seconds...

kubectl run -it --rm --image=mysql:8.0 --restart=Never mysql-client -- mysql -h mysql -ppassword

# USE employees;
# SELECT * FROM employees LIMIT 40;
# SELECT COUNT(*) FROM employees;
