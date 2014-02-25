#!/bin/bash

MYSQL_PASS=$1

sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/metral/touchstone.git ~/touchstone

cd ~/touchstone/encoder/data_master

./install.sh $MYSQL_PASS
