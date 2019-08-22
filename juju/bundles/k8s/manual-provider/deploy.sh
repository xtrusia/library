#!/bin/bash

./bootstrap.sh

#../add-model.sh

machines=(01 02 03 04 05 06 07 08 09 10)

machines_id=( akqkn4 ad6cem wxpm8w 47b8e6 4f4ypk 6dmy6t kpxa8r 4bghnd xbm6ra yfhrkc )

for i in ${machines_id[@]}
do
  maas xtrusia machine deploy $i distro_series=xenial user_data=I2Nsb3VkLWNvbmZpZwptYW5hZ2VfZXRjX2hvc3RzOiBmYWxzZQo=
done

while : ; do
  ncompleted=0
  for i in ${machines_id[@]}
  do
    status=`maas xtrusia machine read $i | jq -r '.status_name'`
    if [ $status == "Deployed" ]; then
      ((ncompleted++))
    fi
  done
  echo "$ncompleted nodes has been deployed"
  if [ $ncompleted -eq 10 ]; then
    break
  fi
done

sleep 300

for i in ${machines[@]}
do
    ssh-keygen -f "/home/xtrusia/.ssh/known_hosts" -R "node-$i.maas"
    juju add-machine ssh:ubuntu@node-$i.maas
done

juju deploy cs:~containers/easyrsa-40 --to 0 --series xenial
juju deploy cs:~containers/etcd-80 --config channel=3.2/stable  -n 3 --to 1,2,3 --series xenial
juju add-relation etcd:certificates easyrsa:client

sleep 1200

juju deploy cs:~containers/canal-34 --config cidr='172.19.0.0/16'
juju deploy cs:~containers/kubeapi-load-balancer-58 --to 4 --series xenial
juju deploy cs:~containers/kubernetes-master-104 --config channel=1.12/stable --config service-cidr='172.18.0.0/16' -n 2 --to 5,6 --series xenial
juju deploy cs:~containers/kubernetes-worker-118 --config channel=1.12/stable -n 3 --to 7,8,9 --series xenial

juju add-relation kubernetes-master:kube-api-endpoint kubeapi-load-balancer:apiserver
juju add-relation kubernetes-master:loadbalancer kubeapi-load-balancer:loadbalancer
juju add-relation kubernetes-master:kube-control kubernetes-worker:kube-control
juju add-relation kubernetes-master:certificates easyrsa:client
juju add-relation kubernetes-master:etcd etcd:db
juju add-relation kubernetes-worker:certificates easyrsa:client
juju add-relation kubernetes-worker:kube-api-endpoint kubeapi-load-balancer:website
juju add-relation kubeapi-load-balancer:certificates easyrsa:client
juju add-relation canal:etcd etcd:db
juju add-relation canal:cni kubernetes-master:cni
juju add-relation canal:cni kubernetes-worker:cni
