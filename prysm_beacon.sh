#!/usr/bin/env bash

#
# Starts prysm beacon node based upon a genesis state.
#

set -Eeuo pipefail

source ./vars.env

LOG_LEVEL="debug" # (trace, debug, info=default, warn, error, fatal, panic) (default: "info")

# Get positional arguments
data_dir=${@:$OPTIND+0:1}
bootnode_yaml=${@:$OPTIND+1:1}
exec_endpoint=${@:$OPTIND+2:1}
rpc_port=${@:$OPTIND+3:1}
p2p_udp_port=${@:$OPTIND+4:1}
grpc_gateway=${@:$OPTIND+5:1}


echo "--datadir=$data_dir"
echo "--bootstrap-node=$bootnode_yaml"
echo "--execution-endpoint="http://localhost:$exec_endpoint""
echo "--rpc-port=$rpc_port"
echo "--p2p-udp-port=$p2p_udp_port"
echo "--grpc-gateway-port=$grpc_gateway"

$BUILD_DIR/beacon-chain \
    --min-sync-peers=0 \
    --chain-id=$CHAIN_ID \
    --accept-terms-of-use \
    --datadir=$data_dir \
    --force-clear-db \
    --bootstrap-node=$bootnode_yaml \
    --execution-endpoint="http://localhost:$exec_endpoint" \
    --jwt-secret=$JWT_SECRET \
    --chain-config-file=$CL_CONFIG/prysm_config.yaml \
    --contract-deployment-block 0 \
    --deposit-contract=$DEPOSIT_CONTRACT_ADDRESS \
    --rpc-port=$rpc_port \
    --p2p-udp-port=$p2p_udp_port \
    --grpc-gateway-port=$grpc_gateway \
    --p2p-local-ip 127.0.0.1 \
    --enable-debug-rpc-endpoints \
    --suggested-fee-recipient=$DEPOSIT_CONTRACT_ADDRESS \
    --subscribe-all-subnets \
    --verbosity=$LOG_LEVEL \

