#!/usr/bin/env bash
# Start all processes necessary to create a local testnet

set -Eeuo pipefail


# reset the GENESIS_TIMESTAMP so the chain starts shortly after
DATE=$(date +%s)
sed -i "s/export GENESIS_TIMESTAMP=.*/export GENESIS_TIMESTAMP=$(($DATE + 60))/" ./vars.env

source ./vars.env

# Set a higher ulimit in case we want to import 1000s of validators.
ulimit -n 65536

# VC_COUNT is defaulted in vars.env
DEBUG_LEVEL=${DEBUG_LEVEL:-info}
BUILDER_PROPOSALS=

# Get options
while getopts "v:d:ph" flag; do
  case "${flag}" in
    v) VC_COUNT=${OPTARG};;
    d) DEBUG_LEVEL=${OPTARG};;
    p) BUILDER_PROPOSALS="-p";;
    h)
        validators=$(( $VALIDATOR_COUNT / $BN_COUNT ))
        echo "Start local testnet, defaults: 1 eth1 node, $BN_COUNT beacon nodes,"
        echo "and $VC_COUNT validator clients with each vc having $validators validators."
        echo
        echo "usage: $0 <Options>"
        echo
        echo "Options:"
        echo "   -v: VC_COUNT    default: $VC_COUNT"
        echo "   -d: DEBUG_LEVEL default: info"
        echo "   -p:             enable private tx proposals"
        echo "   -h:             this help"
        exit
        ;;
  esac
done

if (( $LH_VC_COUNT > $LH_BN_COUNT )); then
    echo "Error $LH_VC_COUNT is too large, must be <= BN_COUNT=$LH_BN_COUNT"
    exit
fi

# Init some constants
PID_FILE=$DATADIR/PIDS.pid
LOG_DIR=$LOGDIR/logs

# Stop local devnet and remove $PID_FILE
./stop_local_devnet.sh

# Clean $DATADIR and create empty log files so the
# user can "tail -f" right after starting this script
# even before its done.
./clean.sh
mkdir -p $LOG_DIR

# Sleep with a message
sleeping() {
   echo sleeping $1
   sleep $1
}

# Execute the command with logs saved to a file.
#
# First parameter is log file name
# Second parameter is executable name
# Remaining parameters are passed to executable
execute_command() {
    LOG_NAME=$1
    EX_NAME=$2
    shift
    shift
    CMD="$EX_NAME $@ >> $LOG_DIR/$LOG_NAME 2>&1"
    echo "executing: $CMD"
    echo "$CMD" > "$LOG_DIR/$LOG_NAME"
    eval "$CMD &"
}

# Execute the command with logs saved to a file
# and is PID is saved to $PID_FILE.
#
# First parameter is log file name
# Second parameter is executable name
# Remaining parameters are passed to executable
execute_command_add_PID() {
    execute_command $@
    echo "$!" >> $PID_FILE
}

# generate JWT secret
./jwt.sh

# generate EL genesis state
./gen_el_genesis.sh

# Start EL nodes
EL_private_api_addr_base=9089
EL_http_port_base=8544
EL_authrpc_port_base=8550
EL_torrent_port_base=42068
EL_port_base=30300

execute_command_add_PID el_bootnode.log ./el_bootnode.sh $EL_port_base
sleeping 5

EL_bootnode=$(sed -n -e "/^enode:/p" $LOG_DIR/el_bootnode.log)

for (( n=1; n<=$ERIGON_NODES; n++ )); do
    execute_command_add_PID erigon_$n.log ./erigon.sh $DATADIR/node_$n/erigon $((EL_private_api_addr_base + $n)) $((EL_http_port_base + $n)) $((EL_authrpc_port_base + $n)) $((EL_torrent_port_base + $n)) $((EL_port_base + $n)) $EL_bootnode
    sleeping 3
done
sleeping 3

RPC_http_port_base=12344
for (( n=1; n<=1; n++ )); do
    execute_command_add_PID rpcdaemon_$n.log ./rpcdaemon.sh $DATADIR/node_$n/erigon $((RPC_http_port_base + $n)) $((EL_private_api_addr_base + $n)) 
done
sleeping 5

# Generate CL genesis state
./gen_cl_genesis.sh

# Delay to let boot_enr.yaml to be created
execute_command_add_PID cl_bootnode.log ./cl_bootnode.sh
sleeping 1


# Start beacon nodes
BN_udp_tcp_base=9000
BN_http_port_base=8000

(( $LH_VC_COUNT < $LH_BN_COUNT )) && SAS=-s || SAS=

for (( bn=1; bn<=$LH_BN_COUNT; bn++ )); do
    execute_command_add_PID lighthouse_beacon_$bn.log ./lighthouse_beacon.sh $SAS -d $DEBUG_LEVEL $DATADIR/node_$bn $((BN_udp_tcp_base + $bn)) $((BN_http_port_base + $bn)) $((EL_authrpc_port_base + $bn))
done

sleeping 5

# Start requested number of validator clients
for (( vc=1; vc<=$LH_VC_COUNT; vc++ )); do
    execute_command_add_PID lighthouse_validator_$vc.log ./lighthouse_validator.sh $BUILDER_PROPOSALS -d $DEBUG_LEVEL $DATADIR/node_$vc http://localhost:$((BN_http_port_base + $vc))
done

echo "Lighthouse nodes Started!"


data_dir=${@:$OPTIND+0:1}
bootnode_yaml=${@:$OPTIND+1:1}
exec_endpoint=${@:$OPTIND+2:1}
rpc_port=${@:$OPTIND+3:1}

P2P_UDP_PORT=9999
GRPC_GATEWAY=2999
for (( bn=$((LH_BN_COUNT+1)); bn<=$((LH_BN_COUNT + PR_BN_COUNT)); bn++ )); do
    c=$((bn-PR_BN_COUNT))
    execute_command_add_PID prysm_node_$c.log ./prysm_beacon.sh $DATADIR/node_$bn/prysm_bn $CL_CONFIG/boot_enr.yaml $((EL_authrpc_port_base + $c)) $((BN_http_port_base + $c)) $((P2P_UDP_PORT + $c)) $((GRPC_GATEWAY + $c)) 
    sleeping 3
done





