#!/bin/bash

machine=${1:-0}
model=${2:-controller}

read -d '' -r cmds <<'EOF'
conf=/var/lib/juju/agents/machine-*/agent.conf
user=`sudo grep tag $conf | cut -d' ' -f2`
password=`sudo grep statepassword $conf | cut -d' ' -f2`
mongodump --host 127.0.0.1:37017 --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --username "$user" --password "$password"
EOF

juju ssh -m $model $machine "$cmds"
