#!/bin/bash

BRANCH=$1
RSYSLOG_SERVER_IP=$2

sudo apt-get update
sudo apt-get install git -y

CLONE_PATH=~/touchstone
#git clone https://github.com/metral/touchstone.git $CLONE_PATH
pushd $CLONE_PATH

if [ "$BRANCH" != "master" ]; then
    git checkout -b $BRANCH origin/$BRANCH
fi

pushd logging/rsyslog/client
./install.sh $RSYSLOG_SERVER_IP
popd

popd
