#!/usr/bin/env bash

set -Eeuo pipefail

source ./vars.env

LOG_LEVEL="debug" # (trace, debug, info=default, warn, error, fatal, panic) (default: "info")

# Get positional arguments
data_dir=${@:$OPTIND+0:1}
rpc_port=${@:$OPTIND+1:1}

echo "--datadir=$data_dir"
echo "--beacon-rpc-provider="127.0.0.1:$rpc_port""

$BUILD_DIR/validator \
    --datadir=$data_dir \
    --accept-terms-of-use \
    --interop-num-validators=$VALIDATOR_COUNT \
    --interop-start-index=0 \
    --force-clear-db \
    --chain-config-file=$CL_CONFIG/prysm_config.yaml \
    --beacon-rpc-provider="127.0.0.1:$rpc_port" \
    --verbosity=$LOG_LEVEL \