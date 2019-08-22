#!/bin/bash
# This file gets juju tools from the other unit and make tools directory for broken unit.
# 

unit=${1:-etcd/0}
origin_unit=${2:-etcd/2}
machine=${3:-machine-6}

unit_dir_fmt=unit-${unit/\//-}

tool=(`juju ssh $origin_unit -o LogLevel=QUIET ls /var/lib/juju/tools/`)
tool_name=${tool[0]}

echo "Getting tools from the other node and copying it to target unit.."

mkdir -p tmp/$tool_name
juju ssh $unit -o LogLevel=QUIET "sudo mkdir -p /var/lib/juju/tools/$tool_name"
juju scp -- -o LogLevel=QUIET -r $origin_unit:/var/lib/juju/tools/$tool_name/jujud tmp/$tool_name/
juju scp -- -o LogLevel=QUIET -r $origin_unit:/var/lib/juju/tools/$tool_name/downloaded-tools.txt tmp/$tool_name/
juju ssh $unit -o LogLevel=QUIET "sudo rm -rf ~/$tool_name"
juju scp -- -o LogLevel=QUIET -r tmp/$tool_name $unit:~/
juju ssh $unit -o LogLevel=QUIET "sudo chown -R root:root ~/$tool_name"
juju ssh $unit -o LogLevel=QUIET "sudo mv ~/$tool_name /var/lib/juju/tools/"

echo "Creating unit tools symlink.."
# Create unit tools sym link
cmd=( action-fail action-get action-set add-metric application-version-set close-port config-get credential-get goal-state is-leader juju-log juju-reboot leader-get leader-set network-get open-port opened-ports payload-register payload-status-set payload-unregister pod-spec-set relation-get relation-ids relation-list relation-set resource-get status-get status-set storage-add storage-get storage-list unit-get )

for i in ${cmd[@]}
do
  juju ssh $unit -o LogLevel=QUIET "sudo ln -s /var/lib/juju/tools/$tool_name/jujud /var/lib/juju/tools/$tool_name/$i"
done

# Create unit tools sym link
juju ssh $unit -o LogLevel=QUIET "sudo ln -s /var/lib/juju/tools/$tool_name /var/lib/juju/tools/$unit_dir_fmt"
juju ssh $unit -o LogLevel=QUIET "sudo ln -s /var/lib/juju/tools/$tool_name /var/lib/juju/tools/$machine"

echo "Done."
