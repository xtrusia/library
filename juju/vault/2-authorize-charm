#!/bin/bash

token=`jq -r '.auth.client_token' t`

juju run-action --wait vault/leader authorize-charm token=$token
