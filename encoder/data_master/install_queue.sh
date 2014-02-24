#!/bin/bash

# update apt repos
sudo apt-get update
sudo apt-get install make -y

# install gearman deps
sudo apt-get install libboost-all-dev libboost-thread-dev libboost-program-options-dev gperf libevent-dev libuuid1 uuid-dev gperf htop -y

# download & compile gearman
wget https://launchpad.net/gearmand/1.2/1.1.12/+download/gearmand-1.1.12.tar.gz
tar xzvf gearmand*.tar.gz
cd gearman*

./configure
NUM_CPUS=`cat /proc/cpuinfo | grep processor | wc -l`
make -j$NUM_CPUS
sudo make install
cd ../

# install easy_install, pip & python gearman client api
sudo apt-get install python-setuptools -y
sudo easy_install pip
sudo pip install gearman

# clean up
rm -rf gearmand*

# start gearman
sudo touch /var/log/gearmand.log
sudo gearmand -d -l /var/log/gearmand.log
