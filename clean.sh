#!/usr/bin/env bash

#
# Deletes all files associated with the local testnet.
#

set -Eeuo pipefail

source ./vars.env

# ./stop_local_testnet.sh

if [ -d $DATADIR ]; then
  rm -r $DATADIR
fi

# echo $ERIGON_NODES
