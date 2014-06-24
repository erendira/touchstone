#!/bin/bash

BRANCH=$1

sudo apt-get update
sudo apt-get install git -y

git clone https://github.com/metral/touchstone.git ~/touchstone

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

pushd ~/touchstone/logging/webapp
./install.sh
popd
