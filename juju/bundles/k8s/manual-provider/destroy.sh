#!/bin/bash

host=( 0 1 2 3 4 5 6 7 8 9 )

for i in ${host[@]}
do
    juju remove-machine --force $i
done

juju remove-application canal
juju remove-application easyrsa
juju remove-application etcd
juju remove-application kubeapi-load-balancer
juju remove-application kubernetes-master
juju remove-application kubernetes-worker

#juju destroy-model -y maas
#juju destroy-model -y default
juju kill-controller -y maas

./clear_machine.sh

machines_id=( akqkn4 ad6cem wxpm8w 47b8e6 4f4ypk 6dmy6t kpxa8r 4bghnd xbm6ra yfhrkc )

for i in ${machines_id[@]}
do
  maas xtrusia machine release $i
  while : ; do
    status=`maas xtrusia machine read $i | jq -r '.status_name'`
    echo $status
    if [ "$status" = "Ready" ]; then
      break
    fi
  done
done
