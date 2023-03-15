#!/usr/bin/env bash

# Create EL genesis.json see apps/el-gen/genesis_gen.py

set -Eeuo pipefail

source ./vars.env


if ! [ -f "$EL_GENESIS" ]; then
    mkdir -p $EL_CONFIG
    envsubst < ./config/el/genesis-config.yaml > $EL_CONFIG/genesis-config.yaml
    cur_dir=$(pwd)
    cd ./apps/el-gen/ && pip3 install -r requirements.txt
    cd $cur_dir
    python3 ./apps/el-gen/genesis_gen.py $EL_CONFIG/genesis-config.yaml      > $EL_GENESIS
else
    echo "el genesis already exists. skipping generation..."
fi


