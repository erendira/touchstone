#!/bin/bash

EXPECTEDARGS=4
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <RAX_USERNAME> <RAX_APIKEY> <DATA_MASTER_IP> <MYSQL_PASS>"
    exit 0
fi

RAX_USERNAME=$1
RAX_APIKEY=$2
DATA_MASTER_IP=$3
MYSQL_PASS=$4

# setup & install mysql client
sudo apt-get update
sudo apt-get install mysql-client-core-5.5 -y

# install easy_install, pip, gearman api
sudo apt-get install python-setuptools python-mysqldb -y
sudo easy_install pip
sudo pip install gearman pyrax

# install ffmpeg & deps
sudo apt-get install python-sphinx -y

wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-2.1.3-64bit-static.tar.bz2
tar xvf ffmpeg*
mv ffmpeg*/ff* /usr/local/bin/
mv ffmpeg*/qt* /usr/local/bin/
rm -rf ffmpeg*

git clone https://github.com/senko/python-video-converter.git
cd python-video-converter
python setup.py install
cd ../
rm -rf python-video-converter

# pyrax creds for RAX
(cat | sudo tee ~/pyrax_rc) << EOF
[rackspace_cloud]
username = $RAX_USERNAME
api_key = $RAX_APIKEY
EOF
