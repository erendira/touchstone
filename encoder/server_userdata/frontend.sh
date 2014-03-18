#!/bin/bash

WEBAPP_IP=$1
BRANCH=$2

sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/metral/touchstone.git ~/touchstone

cd ~/touchstone/encoder/frontend

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

./install.sh
./update.sh $WEBAPP_IP
