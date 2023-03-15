#!/usr/bin/env bash
# Stop all processes that were started with start_local_testnet.sh

set -Eeuo pipefail

source ./vars.env

PID_FILE=$DATADIR/PIDS.pid
./kill_processes.sh $PID_FILE

sleep 2 
# run again since erigon bootnode does not shut down right away
PID_FILE=$DATADIR/PIDS.pid
./kill_processes.sh $PID_FILE

rm -f $PID_FILE
