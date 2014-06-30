#!/bin/bash

BRANCH=$1

sudo apt-get update
sudo apt-get install git -y

CLONE_PATH=~/touchstone
git clone https://github.com/metral/touchstone.git $CLONE_PATH
pushd $CLONE_PATH

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

pushd logging/elk
./install.sh
popd

popd
