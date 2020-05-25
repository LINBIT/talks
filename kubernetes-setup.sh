#!/bin/bash

# These are primarily notes, the commands may need some adjustment for local use

set -e

parallel --tag -j0 --line-buffer virter vm run --id 10{1} --name centos-7-k8s-10{1} -m {2}G --vcpus 4 --wait-ssh centos-7-k8s-1-18 ::: {0..4} :::+ 3 3 3 4 4

# run in linstor-kubernetes-tests
virter vm exec -p provision-install-1-18-weave.toml centos-7-k8s-10{0..4}

# make some change so that scheduler restarts with required permissions
virter vm exec --set "steps[0].shell.script=sed -i 's/cpu: ...m/cpu: 101m/' /etc/kubernetes/manifests/kube-scheduler.yaml" centos-7-k8s-100

# add kernel-devel for piraeus
virter vm exec --set "steps[0].shell.script=yum install -y kernel-devel" centos-7-k8s-10{1..4}

# add thin lvm support
virter vm exec --set "steps[0].shell.script=modprobe dm_thin_pool" centos-7-k8s-10{1..4}

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.122.100:/etc/kubernetes/admin.conf ~/.kube/config
