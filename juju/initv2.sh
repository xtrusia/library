#!/bin/bash

set -ex

. ./common

[[ -z "$GATEWAY" ]] && export GATEWAY="10.0.1.10"
[[ -z "$CIDR_EXT" ]] && export CIDR_EXT="10.0.1.0/24"
[[ -z "$FIP_RANGE" ]] && export FIP_RANGE="10.0.1.200:10.0.1.254"
[[ -z "$NAMESERVER" ]] && export NAMESERVER="8.8.8.8"
[[ -z "$CIDR_PRIV" ]] && export CIDR_PRIV="192.168.21.0/24"

net_type=${1:-"gre"}


source novarc
./bin/neutron-ext-net --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
./bin/neutron-tenant-net --network-type $net_type -t admin -r provider-router -N $NAMESERVER private $CIDR_PRIV
ext_net=$(openstack network list | awk '/ext_net/ {print $2}')

# Download images if not already present
mkdir -vp ~/images
upload_image cloudimages xenial xenial-server-cloudimg-amd64-disk1.img
upload_image cloudimages trusty trusty-server-cloudimg-amd64-disk1.img
image_id=$(openstack image list | awk '/cirros\s/ {print $2}')
image_alt_id=$(openstack image list | awk '/cirros2\s/ {print $2}')

#create_default_flavors
shrink_flavors

openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey

#openstack security rule create --protocol icmp --direction ingress default
#openstack security rule create --protocol tcp --port-range-min 22 --port-range-max 22 --direction ingress default

#openstack serve create --image trusty --flavor m1.small --key-name mykey
