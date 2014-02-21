#!/bin/bash

RAX_USERNAME=$1
RAX_APIKEY=$2

sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/metral/touchstone.git ~/touchstone

cd ~/touchstone/encoder/webapp

./install.sh $RAX_USERNAME $RAX_APIKEY
