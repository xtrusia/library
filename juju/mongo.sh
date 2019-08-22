#!/bin/bash

#!/bin/bash

machine=${1:-0}
model=${2:-controller}

read -d '' -r cmds <<'EOF'
conf=/var/lib/juju/agents/machine-*/agent.conf
user=`sudo grep tag $conf | cut -d' ' -f2`
password=`sudo grep statepassword $conf | cut -d' ' -f2`
/usr/lib/juju/mongo*/bin/mongo 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --username "$user" --password "$password"
EOF
#/usr/bin/mongo 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --username "$user" --password "$password"

juju ssh -m $model $machine "$cmds"
