#!/bin/bash

machines=( 01 02 03 04 05 06 07 08 09 10 )

for i in ${machines[@]}
do
  ssh ubuntu@node-$i.maas "sudo apt remove juju*"
  ssh ubuntu@node-$i.maas "sudo rm /etc/systemd/system/jujud*" 
  ssh ubuntu@node-$i.maas "sudo rm -rf /var/lib/juju"
  ssh ubuntu@node-$i.maas "sudo rm /usr/bin/juju-run"
done
