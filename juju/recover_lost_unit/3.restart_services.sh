#!/bin/bash

unit=${1:-etcd/0}
machine=${2:-machine-6}

unit_dir_fmt=unit-${unit/\//-}

#restart daemons
juju ssh $unit -o LogLevel=QUIET "sudo systemctl stop jujud-$unit_dir_fmt.service"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl stop jujud-$machine.service"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl stop snap.etcd.etcd.service"
juju ssh $unit -o LogLevel=QUIET "sudo cd /var/snap/etcd/current/member/; rm -rf *"
juju ssh $unit -o LogLevel=QUIET "sudo ls /var/snap/etcd/current/member/"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl start snap.etcd.etcd.service"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl daemon-reload"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl start jujud-$unit_dir_fmt.service"
juju ssh $unit -o LogLevel=QUIET "sudo systemctl start jujud-$machine.service"
