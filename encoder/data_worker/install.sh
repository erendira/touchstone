#!/bin/bash

EXPECTEDARGS=4
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <RAX_USERNAME> <RAX_APIKEY> <MYSQL_PASS> <DATA_MASTER_IP>"
    exit 0
fi

RAX_USERNAME=$1
RAX_APIKEY=$2
MYSQL_PASS=$3
DATA_MASTER_IP=$4
MYSQL_DB="encoder"
MYSQL_USER="rax"

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