#!/bin/bash

BRANCH=$1

sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/metral/touchstone.git ~/touchstone

cd ~/touchstone/logging/webapp

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

./install.sh
