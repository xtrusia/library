#!/bin/bash

juju bootstrap maas --no-gui --model-default agent-metadata-url="http://192.168.0.5/" --metadata-source=~/agents
juju model-config apt-mirror=http://192.168.0.5/ubuntu/
