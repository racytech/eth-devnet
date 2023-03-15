#!/usr/bin/env bash

# Create JWT auth token for EL and CL connection

set -Eeuo pipefail

source ./vars.env
 
if ! [ -f "$JWT_SECRET" ]; then
    mkdir -p $JWT_PATH
    echo -n 0x$(openssl rand -hex 32 | tr -d "\n") > $JWT_SECRET
else
    echo "JWT secret already exists. skipping generation..."
fi