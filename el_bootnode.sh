#!/usr/bin/env bash



port=${@:$OPTIND+0:1}


$BUILD_DIR/bootnode -genkey boot.key

exec $BUILD_DIR/bootnode -nodekey boot.key -addr :$port 
