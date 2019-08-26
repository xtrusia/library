#!/bin/bash

juju_data=`juju status --format json | jq '.'`

units=$( echo $juju_data | jq  -r '.applications | .[].units')

echo $units

#for unit in "${units[@]}"
#do
#  echo "==================================="
#  echo $unit
#  echo "==================================="
#done




#juju run --unit kubernetes-master/0 -- 'charms.reactive get_flags'
