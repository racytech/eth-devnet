#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail

source ./vars.env

mkdir -p $CL_CONFIG
# Replace environment vars in files
envsubst < ./config/cl/config.yaml > $CL_CONFIG/config.yaml
envsubst < ./config/cl/mnemonics.yaml > $CL_CONFIG/mnemonics.yaml
envsubst < ./config/cl/config.yaml > $CL_CONFIG/prysm_config.yaml

echo $DEPOSIT_CONTRACT_BLOCK > $CL_CONFIG/deploy_block.txt
echo $CL_EXEC_BLOCK > $CL_CONFIG/deposit_contract_block.txt

# generate lighthouse validators
$BUILD_DIR/lcli \
	insecure-validators \
	--count $VALIDATOR_COUNT \
	--base-dir $DATADIR \
	--node-count $LH_BN_COUNT

echo Validators generated with keystore passwords at $DATADIR.
echo "Building genesis state... (this might take a while)"

$BUILD_DIR/lcli \
	interop-genesis \
	--spec $SPEC_PRESET \
	--genesis-time $GENESIS_TIMESTAMP \
	--testnet-dir $CL_CONFIG \
	$GENESIS_VALIDATOR_COUNT

echo Created genesis state in $CL_CONFIG

$BUILD_DIR/lcli pretty-ssz state_merge $CL_CONFIG/genesis.ssz > $CL_CONFIG/parsed.json


