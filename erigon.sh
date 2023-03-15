#!/usr/bin/env bash

# Start Erigon nodes see start local 

source ./vars.env

# Get positional arguments
data_dir=${@:$OPTIND+0:1}
paa_port=${@:$OPTIND+1:1}
rpc_port=${@:$OPTIND+2:1}
auth_port=${@:$OPTIND+3:1}
torrent_port=${@:$OPTIND+4:1}
p2p_port=${@:$OPTIND+5:1}
bootnode=${@:$OPTIND+6:1}


echo "--datadir=$data_dir"
echo "--private.api.addr=$paa_port"
echo "--http.port=$rpc_port"
echo "--authrpc.port=$auth_port"
echo "--torrent.port=$torrent_port"
echo "--port=$p2p_port"
echo "--bootnodes=$bootnode"


LOG_LEVEL="dbug"
ADDITIONAL_FLAGS="--nat extip:$EXTERNAL_IP --netrestrict $EXTERNAL_IP/24" # change EXTERNAL_IP manually in vars.env

echo $ADDITIONAL_FLAGS

$BUILD_DIR/erigon init --datadir=$data_dir $EL_GENESIS

exec $BUILD_DIR/erigon \
    --externalcl \
    --datadir $data_dir \
    --private.api.addr=localhost:$paa_port \
    --networkid=$NETWORK_ID \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=127.0.0.1 \
    --http.port=$rpc_port \
    --http.api=web3,debug,engine,eth,net,txpool \
    --authrpc.addr=0.0.0.0 \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret=$JWT_SECRET \
    --authrpc.port=$auth_port \
    --ws \
    --log.console.verbosity=$LOG_LEVEL \
    --torrent.port=$torrent_port \
    --allow-insecure-unlock \
    --port=$p2p_port \
    --p2p.protocol=68 \
    --sentry.log-peer-info \
    --bootnodes=$bootnode \
    $ADDITIONAL_FLAGS \
    # --mine \
    # --miner.etherbase="0x67b1d87101671b127f5f8714789C7192f7ad340e"

