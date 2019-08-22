#!/bin/bash

pass=`./passgen`
passhash=`./passhashgen $pass`

pass2=`./passgen`
passhash2=`./passhashgen $pass2`

unit=${1:-etcd/0}
origin_unit=${2:-etcd/2}
charm=${3:-etcd-332}
controller=${4:-controller}
cmachine=${5:-0}

machine=${6:-machine-6}
origin_machine=${7:-machine-8}
machineid=(${machine//-/ })
machineid=${machineid[1]}

modeluuid=${8:-00f679ad-6797-47dc-8fc5-f4ea2b47bf87}

origin_unit_dir_fmt=unit-${origin_unit/\//-}
unit_dir_fmt=unit-${unit/\//-}

#Collect the other node's agent.conf and charm from charmstore

mkdir -p tmp/agents/$unit_dir_fmt/charm
mkdir -p tmp/agents/$machine

wget -O tmp/agents/$unit_dir_fmt/$charm.zip https://api.jujucharms.com/charmstore/v5/~containers/$charm/archive
unzip -o tmp/agents/$unit_dir_fmt/$charm.zip -d tmp/agents/$unit_dir_fmt/charm/
rm tmp/agents/$unit_dir_fmt/$charm.zip

juju ssh $origin_unit -o LogLevel=QUIET "sudo cp /var/lib/juju/agents/$origin_unit_dir_fmt/agent.conf ~/"
juju ssh $origin_unit -o LogLevel=QUIET "sudo chown ubuntu:ubuntu agent.conf"
juju scp -- -o LogLevel=QUIET -r $origin_unit:~/agent.conf tmp/agents/$unit_dir_fmt/

juju ssh $origin_unit -o LogLevel=QUIET "sudo cp /var/lib/juju/agents/$origin_machine/agent.conf ~/"
juju ssh $origin_unit -o LogLevel=QUIET "sudo chown ubuntu:ubuntu agent.conf"
juju scp -- -o LogLevel=QUIET -r $origin_unit:~/agent.conf tmp/agents/$machine/

#Modify agent.conf
echo "Modifying agent.conf"

sed -i "s/$origin_unit_dir_fmt/$unit_dir_fmt/g" tmp/agents/$unit_dir_fmt/agent.conf
echo $pass
sed -i "s/apipassword\:.*/apipassword\: $pass/g" tmp/agents/$unit_dir_fmt/agent.conf

sed -i "s/$origin_machine/$machine/g" tmp/agents/$machine/agent.conf
echo $pass2
sed -i "s/apipassword\:.*/apipassword\: $pass2/g" tmp/agents/$machine/agent.conf

#Get machine nonce
echo "Get machine nonce"

#!/bin/bash

read -d '' -r cmds <<'EOF'
conf=/var/lib/juju/agents/machine-*/agent.conf
user=`sudo grep tag $conf | cut -d' ' -f2`
password=`sudo grep statepassword $conf | cut -d' ' -f2`
release=`cat /etc/os-release | sed -ne '/UBUNTU_CODENAME=\(.*\)/{ s//\1/p }'`
if [ "$release" == "bionic" ]; then
  echo "Bionic"
  mongopath="/usr/bin/mongo"
else
  echo "Xenial"
  mongopath="/usr/lib/juju/mongo*/bin/mongo"
fi
$mongopath 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames --username "$user" --password "$password" \
--eval 'db.machines.find({machineid:"
EOF
cmds="$cmds$machineid\", \"model-uuid\": \"$modeluuid\"}, {nonce:1})'"

nonce=`juju ssh -m $controller $cmachine -o LogLevel=QUIET "$cmds" | sed '7q;d' | jq -r '.nonce'`

echo "nonce : $nonce"

#Update machine nonce for agent.conf

sed -i "s/nonce\:.*/nonce\: $nonce/g" tmp/agents/$machine/agent.conf

#copy to broken node

juju ssh $unit -o LogLevel=QUIET "sudo mkdir -p /var/lib/juju/agents/"

juju scp -- -o LogLevel=QUIET -r tmp/agents/$unit_dir_fmt $unit:~/
juju ssh $unit -o LogLevel=QUIET "sudo cp -a ~/$unit_dir_fmt /var/lib/juju/agents/"

juju scp -- -o LogLevel=QUIET -r tmp/agents/$machine $unit:~/
juju ssh $unit -o LogLevel=QUIET "sudo cp -a ~/$machine /var/lib/juju/agents/"

#Modify mongodb on controller node
echo "Update mongodb : for unit"

read -d '' -r cmds <<'EOF'
conf=/var/lib/juju/agents/machine-*/agent.conf
user=`sudo grep tag $conf | cut -d' ' -f2`
password=`sudo grep statepassword $conf | cut -d' ' -f2`
release=`cat /etc/os-release | sed -ne '/UBUNTU_CODENAME=\(.*\)/{ s//\1/p }'`
if [ "$release" == "bionic" ]; then
  echo "Bionic"
  mongopath="/usr/bin/mongo"
else
  echo "Xenial"
  mongopath="/usr/lib/juju/mongo*/bin/mongo"
fi
$mongopath 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames --username "$user" --password "$password" \
--eval 'db.units.update({name:"
EOF
cmds="$cmds$unit\", \"model-uuid\": \"$modeluuid\"}, { \$set: { passwordhash: \"$passhash\"}})'"

juju ssh -m $controller $cmachine -o LogLevel=QUIET "$cmds"

echo "Update mongoda : for machineb"

read -d '' -r cmds <<'EOF'
conf=/var/lib/juju/agents/machine-*/agent.conf
user=`sudo grep tag $conf | cut -d' ' -f2`
password=`sudo grep statepassword $conf | cut -d' ' -f2`
release=`cat /etc/os-release | sed -ne '/UBUNTU_CODENAME=\(.*\)/{ s//\1/p }'`
if [ "$release" == "bionic" ]; then
  echo "Bionic"
  mongopath="/usr/bin/mongo"
else
  echo "Xenial"
  mongopath="/usr/lib/juju/mongo*/bin/mongo"
fi
$mongopath 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --sslAllowInvalidHostnames --username "$user" --password "$password" \
--eval 'db.machines.update({machineid:"
EOF
cmds="$cmds$machineid\", \"model-uuid\": \"$modeluuid\"}, { \$set: { passwordhash: \"$passhash2\"}})'"

juju ssh -m $controller $cmachine -o LogLevel=QUIET "$cmds"
