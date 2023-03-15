#!/usr/bin/env bash

source ./vars.env

# Get positional arguments
data_dir=${@:$OPTIND+0:1}
http_port=${@:$OPTIND+1:1}
paa_port=${@:$OPTIND+2:1}

echo "--datadir=$data_dir"
echo "--private.api.addr=$paa_port"
echo "--http.port=$http_port"

exec $BUILD_DIR/rpcdaemon \
    --log.console.verbosity="dbug" \
    --datadir=$data_dir  \
    --private.api.addr=localhost:$paa_port \
    --http.api=eth,erigon,web3,net,debug,trace,txpool,parity \
    --http.port=$http_port