#!/bin/bash

~/0-juju/older-juju/juju-2.3/bin/juju bootstrap maas --agent-version=2.3.7 --no-gui --bootstrap-constraints="tags=bootstrap" --no-gui --model-default agent-metadata-url="http://192.168.0.5/" --metadata-source=~/agents
