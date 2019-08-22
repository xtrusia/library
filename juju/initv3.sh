#!/bin/bash

set -ex

. ./common

[[ -z "$GATEWAY" ]] && export GATEWAY="10.0.0.1"
[[ -z "$CIDR_EXT" ]] && export CIDR_EXT="10.0.0.0/24"
[[ -z "$FIP_RANGE" ]] && export FIP_RANGE="10.0.0.200:10.0.0.254"
[[ -z "$NAMESERVER" ]] && export NAMESERVER="8.8.8.8"
[[ -z "$CIDR_PRIV" ]] && export CIDR_PRIV="11.0.0.0/24"

net_type=${1:-"gre"}


source novarcv3_project
./bin/neutron-ext-net-ksv3 --project admin --network-type flat -g $GATEWAY -c $CIDR_EXT -f $FIP_RANGE ext_net
./bin/neutron-tenant-net-ksv3 --project admin --network-type $net_type -r provider-router -N $NAMESERVER private $CIDR_PRIV -s
ext_net=$(openstack network list | awk '/ext_net/ {print $2}')

# Create demo/testing users, tenants and flavor
openstack project show --domain admin_domain demo || \
        openstack project create --domain admin_domain demo
openstack user show --domain admin_domain demo || \
        openstack user create --project-domain admin_domain --project demo \
        --password pass --enable --email demo@dev.null \
        --domain admin_domain demo
openstack role show Member || openstack role create Member
openstack role add --user-domain admin_domain --user demo \
        --project-domain admin_domain --project demo Member
openstack project show --domain admin_domain alt_demo || \
        openstack project create --domain admin_domain alt_demo
openstack user show --domain admin_domain alt_demo || \
        openstack user create --project-domain admin_domain --project alt_demo \
        --password secret --enable --email alt_demo@dev.null \
        --domain admin_domain alt_demo
openstack role add --user-domain admin_domain --user alt_demo \
        --project-domain admin_domain --project alt_demo Member

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
