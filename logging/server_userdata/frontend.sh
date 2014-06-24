#!/bin/bash

BRANCH=$1
WEBAPP_IP1=$2
WEBAPP_IP2=$3

sudo apt-get update
sudo apt-get install git -y

CLONE_PATH=~/touchstone
git clone https://github.com/metral/touchstone.git $CLONE_PATH
pushd $CLONE_PATH

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

pushd logging/frontend
./install.sh
./update.sh $WEBAPP_IP1 $WEBAPP_IP2
popd

popd
