#!/bin/bash

for i in {1..1000}
do
  ./maas-cli-deployment.sh
  sudo rndc status
  sleep 300
  ./maas-cli-release.sh
  sudo rndc status
  sleep 30
done
