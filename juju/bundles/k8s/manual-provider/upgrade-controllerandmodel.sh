#!/bin/bash

juju upgrade-model -m controller --agent-version 2.4.7
sleep 300
juju upgrade-model -m default --agent-version 2.4.7
