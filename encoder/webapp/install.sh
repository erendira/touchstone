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

# update apt repos
sudo apt-get update

# install deps
sudo apt-get install htop -y

sudo apt-get install python-setuptools -y
sudo easy_install pip
sudo apt-get install python-virtualenv -y

sudo pip install django gunicorn pyrax

# setup virtualenv for webapp
PWD=`pwd`
WEBAPP_PATH=$PWD/django
cd $WEBAPP_PATH
virtualenv --no-site-packages .
cd ../

# pyrax creds for RAX
(cat | sudo tee ~/pyrax_rc) << EOF
[rackspace_cloud]
username = $RAX_USERNAME
api_key = $RAX_APIKEY
EOF

# globals
GUNICORN=gunicorn.sh
GUNICORN_TEMPLATE="gunicorn_template.sh"

# clean up any old conf & scripts
sudo rm $GUNICORN > /dev/null 2>&1
sudo rm /etc/supervisord.conf

# setup gunicorn script from template
sed "s#{WEBAPP_PATH}#$WEBAPP_PATH#g" $GUNICORN_TEMPLATE > $GUNICORN
chmod +x $GUNICORN

# install supervisord
PWD=`pwd`
sed "s#{WEBAPP_PATH}#$PWD#g" supervisord_template.conf | \
    sudo tee /etc/supervisord.conf > /dev/null

sudo mkdir -p /var/log/gunicorn
sudo mkdir -p /var/log/supervisord
sudo pip install supervisor

# start supervisord
sudo supervisorctl stop all
sudo killall -9 supervisord
sudo supervisord -c /etc/supervisord.conf
