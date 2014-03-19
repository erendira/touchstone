#!/bin/bash

EXPECTEDARGS=4
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <RAX_USERNAME> <RAX_APIKEY> <DATA_MASTER_IP> <MYSQL_PASS> <USE_SNET>"
    exit 0
fi

RAX_USERNAME=$1
RAX_APIKEY=$2
DATA_MASTER_IP=$3
MYSQL_PASS=$4
USE_SNET=$5
MYSQL_DB="encoder"
MYSQL_USER="rax"
MYSQL_PORT="3306"

# setup & install mysql client
sudo apt-get update
sudo apt-get install mysql-client-core-5.5 -y

# install easy_install, pip, gearman api
sudo apt-get install python-setuptools python-mysqldb -y
sudo easy_install pip
sudo pip install gearman pyrax
sudo pip install --upgrade pyrax
sudo pip install --upgrade six==1.5.2 requests==2.2.1

# install ffmpeg & deps
sudo apt-get install python-sphinx -y

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-2.1.3-64bit-static.tar.bz2
    tar xvf ffmpeg*
    mv ffmpeg*/ff* /usr/local/bin/
    mv ffmpeg*/qt* /usr/local/bin/
else
    wget http://ffmpeg.gusari.org/static/32bit/ffmpeg.static.32bit.2014-03-01.tar.gz
    tar xvf ffmpeg*
    mv ff* /usr/local/bin/
fi
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

# setup environmental settings
if $USE_SNET ; then
    REGION=`xenstore-read vm-data/provider_data/region`
else
    REGION="dfw"
fi

rm env_settings.py > /dev/null 2>&1

sed -e "s#{MYSQL_PASSWORD}#$MYSQL_PASS#g" \
    -e "s#{MYSQL_HOST}#$DATA_MASTER_IP#g" \
    -e "s#{GEARMAN_SERVER}#$DATA_MASTER_IP#g" \
    -e "s#{REGION}#$REGION#g" \
    -e "s#{USE_SNET}#$USE_SNET#g" \
    -e "s#{MYSQL_DB}#$MYSQL_DB#g" \
    -e "s#{MYSQL_USER}#$MYSQL_USER#g" \
    -e "s#{MYSQL_PORT}#$MYSQL_PORT#g" \
    env_settings_template.py | \
    tee env_settings.py > /dev/null


# install supervisord
sudo rm /etc/supervisord.conf > /dev/null 2>&1
PWD=`pwd`
sed "s#{ENCODER_PATH}#$PWD#g" supervisord_template.conf | \
        sudo tee /etc/supervisord.conf > /dev/null

sudo mkdir -p /var/log/supervisord
sudo pip install supervisor

# start supervisord
sudo supervisorctl stop all
sudo killall -9 supervisord
sudo supervisord -c /etc/supervisord.conf
