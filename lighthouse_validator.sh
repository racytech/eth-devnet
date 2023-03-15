#!/usr/bin/env bash

#
# Starts a validator client based upon a genesis state created by
# `./setup.sh`.
#
# Usage: ./validator_client.sh <DATADIR> <BEACON-NODE-HTTP> <OPTIONAL-DEBUG-LEVEL>

set -Eeuo pipefail

source ./vars.env

DEBUG_LEVEL=info

BUILDER_PROPOSALS=

# Get options
while getopts "pd:" flag; do
  case "${flag}" in
    p) BUILDER_PROPOSALS="--builder-proposals";;
    d) DEBUG_LEVEL=${OPTARG};;
  esac
done

exec $BUILD_DIR/lighthouse \
	--debug-level $DEBUG_LEVEL \
	--logfile-max-number 0 \
	vc \
	$BUILDER_PROPOSALS \
	--datadir ${@:$OPTIND:1} \
	--testnet-dir $CL_CONFIG \
	--init-slashing-protection \
	--beacon-nodes ${@:$OPTIND+1:1} \
	$VC_ARGS \
	--suggested-fee-recipient=$DEPOSIT_CONTRACT_ADDRESS
