#!/bin/bash

WEBAPP_IP=$1

sudo apt-get update
sudo apt-get install git -y
git clone git@github.com:metral/touchstone.git ~/

cd ~/touchstone/encoder/frontend

./install.sh
./update.sh $WEBAPP_IP
