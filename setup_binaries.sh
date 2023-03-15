#!/usr/bin/env bash

#
# Clone repos to this directory and build binaries
#

set -Eeuo pipefail

source ./vars.env

mkdir -p $BUILD_DIR

ERIGON="https://github.com/ledgerwatch/erigon.git"
LIGHTHOUSE="https://github.com/sigp/lighthouse.git"
PRYSM="https://github.com/prysmaticlabs/prysm.git"

ERIGON_BRANCH="devel"
LIGHTHOUSE_BRANCH="unstable"
PRYSM_BRANCH="develop"



print_build() {
    echo ""
    echo "--- Building $1 branch $2 ---"
}


# Erigon
if [ ! -d "./erigon" ]; then
    git clone $ERIGON
fi


cd erigon
print_build erigon $ERIGON_BRANCH
git checkout $ERIGON_BRANCH
git pull origin $ERIGON_BRANCH

make erigon
make rpcdaemon
go build -o=$BUILD_DIR ./cmd/bootnode

cp ./build/bin/erigon $BUILD_DIR
cp ./build/bin/rpcdaemon $BUILD_DIR

cd ..


# Lighthouse 
if [ ! -d "./lighthouse" ]; then
    git clone $LIGHTHOUSE
fi

cd lighthouse
print_build lighthouse $LIGHTHOUSE_BRANCH
git checkout $LIGHTHOUSE_BRANCH
git pull origin $LIGHTHOUSE_BRANCH

make && make install-lcli

cp ~/.cargo/bin/lighthouse $BUILD_DIR
cp ~/.cargo/bin/lcli $BUILD_DIR

cd ..

# Prysm
if [ ! -d "./prysm" ]; then
    git clone $PRYSM
fi

cd prysm
print_build prysm $PRYSM_BRANCH
git checkout $PRYSM_BRANCH
git pull origin $PRYSM_BRANCH

go build -o=$BUILD_DIR ./cmd/beacon-chain
go build -o=$BUILD_DIR ./cmd/validator
go build -o=$BUILD_DIR ./cmd/prysmctl


cd ..

echo DONE!









