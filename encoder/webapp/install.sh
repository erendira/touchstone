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
DJANGO_SECRET_KEY=`tr -dc "[:alpha:]" < /dev/urandom | head -c 64`

# update apt repos
sudo apt-get update

# install deps
sudo apt-get install htop -y

sudo apt-get install python-setuptools python-mysqldb mysql-client -y
sudo easy_install pip
sudo apt-get install python-virtualenv -y

sudo pip install django gunicorn pyrax jsonfield gearman
sudo pip install --upgrade pyrax
sudo pip install --upgrade six==1.5.2 requests==2.2.1

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
sudo rm /etc/supervisord.conf > /dev/null 2>&1

# setup gunicorn script from template
sed "s#{WEBAPP_PATH}#$WEBAPP_PATH#g" $GUNICORN_TEMPLATE > $GUNICORN
chmod +x $GUNICORN

# setup environmental settings
if $USE_SNET ; then
    REGION=`xenstore-read vm-data/provider_data/region`
else
    REGION="dfw"
fi

rm django/encoder_proj/env_settings.py > /dev/null 2>&1

sed -e "s#{MYSQL_PASSWORD}#$MYSQL_PASS#g" \
    -e "s#{MYSQL_HOST}#$DATA_MASTER_IP#g" \
    -e "s#{GEARMAN_SERVER}#$DATA_MASTER_IP#g" \
    -e "s#{REGION}#$REGION#g" \
    -e "s#{USE_SNET}#$USE_SNET#g" \
    -e "s#{MYSQL_DB}#$MYSQL_DB#g" \
    -e "s#{MYSQL_USER}#$MYSQL_USER#g" \
    -e "s#{MYSQL_PORT}#$MYSQL_PORT#g" \
    -e "s#{DJANGO_SECRET_KEY}#$DJANGO_SECRET_KEY#g" \
    env_settings_template.py | \
    tee django/encoder_proj/env_settings.py > /dev/null

# sync db
cd django
CMD="$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h "$DATA_MASTER_IP" encoder -e "show tables" 2>&1)"
ERROR="ERROR"

# wait for mysql host to be up
while [ "${CMD/$ERROR}" != "$CMD" ]; do
    echo "MySQL host not up yet. Waiting ..."
    CMD="$(mysql -u$MYSQL_USER -p$MYSQL_PASS -h "$DATA_MASTER_IP" encoder -e "show tables" 2>&1)"
    sleep 2
done

python manage.py syncdb --noinput
cd ../

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
