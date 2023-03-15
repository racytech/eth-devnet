#!/usr/bin/env bash

#
# Generates a bootnode enr and saves it in $CL_CONFIG/boot_enr.yaml
# Starts a bootnode from the generated enr.
#

set -Eeuo pipefail

source ./vars.env

echo "Generating bootnode enr"

$BUILD_DIR/lcli \
	generate-bootnode-enr \
	--ip 127.0.0.1 \
	--udp-port $BOOTNODE_PORT \
	--tcp-port $BOOTNODE_PORT \
	--genesis-fork-version $GENESIS_FORK_VERSION \
	--output-dir $CL_BOOTNODE

bootnode_enr=`cat $CL_BOOTNODE/enr.dat`
echo "- $bootnode_enr" > $CL_CONFIG/boot_enr.yaml

echo "Generated bootnode enr and written to $CL_CONFIG/boot_enr.yaml"
echo "Starting bootnode"

exec $BUILD_DIR/lighthouse boot_node \
    --testnet-dir $CL_CONFIG \
    --port $BOOTNODE_PORT \
    --listen-address 127.0.0.1 \
	--disable-packet-filter \
    --network-dir $CL_BOOTNODE \
