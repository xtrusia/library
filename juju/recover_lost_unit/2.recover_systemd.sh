#!/bin/bash

# need to be fixed for xenial, tested only for bionic

unit=${1:-etcd/0}
origin_unit=${2:-etcd/2}

unit_dir_fmt=unit-${unit/\//-}
origin_unit_dir_fmt=unit-${origin_unit/\//-}

machine=${3:-machine-6}
origin_machine=${4:-machine-8}
machineid=(${machine//-/ })
machineid=${machineid[1]}
origin_machineid=(${origin_machine//-/ })
origin_machineid=${origin_machineid[1]}

echo $unit
echo $origin_unit

echo $unit_dir_fmt
echo $origin_unit_dir_fmt
echo $machine
echo $origin_machine

rm -rf tmp/systemd/
mkdir -p tmp/systemd/

juju ssh $unit -o LogLevel=QUIET "sudo rm -rf ~/*"

juju scp -- -o LogLevel=QUIET -r $origin_unit:/lib/systemd/system/jujud-$origin_unit_dir_fmt/ tmp/systemd/
juju scp -- -o LogLevel=QUIET -r $origin_unit:/lib/systemd/system/jujud-$origin_machine/ tmp/systemd/

mv tmp/systemd/jujud-$origin_unit_dir_fmt tmp/systemd/jujud-$unit_dir_fmt
mv tmp/systemd/jujud-$origin_machine tmp/systemd/jujud-$machine

sed -i "s/$origin_unit_dir_fmt/$unit_dir_fmt/g" tmp/systemd/jujud-$unit_dir_fmt/exec-start.sh
sed -i "s#$origin_unit#$unit#g" tmp/systemd/jujud-$unit_dir_fmt/exec-start.sh
echo "1"
sed -i "s/$origin_machine/$machine/g" tmp/systemd/jujud-$machine/exec-start.sh
sed -i "s/$origin_machineid/$machineid/g" tmp/systemd/jujud-$machine/exec-start.sh

mv tmp/systemd/jujud-$unit_dir_fmt/jujud-$origin_unit_dir_fmt.service tmp/systemd/jujud-$unit_dir_fmt/jujud-$unit_dir_fmt.service
mv tmp/systemd/jujud-$machine/jujud-$origin_machine.service tmp/systemd/jujud-$machine/jujud-$machine.service

sed -i "s/$origin_unit_dir_fmt/$unit_dir_fmt/g" tmp/systemd/jujud-$unit_dir_fmt/jujud-$unit_dir_fmt.service
sed -i "s#$origin_unit#$unit#g" tmp/systemd/jujud-$unit_dir_fmt/jujud-$unit_dir_fmt.service
echo "2"
sed -i "s/$origin_machine/$machine/g" tmp/systemd/jujud-$machine/jujud-$machine.service

juju scp -- -o LogLevel=QUIET -r tmp/systemd/jujud-$unit_dir_fmt $unit:~/
juju scp -- -o LogLevel=QUIET -r tmp/systemd/jujud-$machine $unit:~/

juju ssh $unit -o LogLevel=QUIET "sudo chown root:root -R ~/jujud-$unit_dir_fmt/"
juju ssh $unit -o LogLevel=QUIET "sudo chown root:root -R ~/jujud-$machine/"
juju ssh $unit -o LogLevel=QUIET "sudo cp -a ~/jujud-$unit_dir_fmt /lib/systemd/system/"
juju ssh $unit -o LogLevel=QUIET "sudo cp -a ~/jujud-$machine /lib/systemd/system/"
