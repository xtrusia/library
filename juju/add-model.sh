#!/bin/bash

juju add-model maas
juju model-config apt-mirror=http://192.168.0.5/ubuntu/
juju model-config agent-metadata-url=http://192.168.0.5/
