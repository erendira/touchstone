#!/bin/bash

DJANGO_SECRET_KEY=`tr -dc "[:alpha:]" < /dev/urandom | head -c 64`

# update apt repos
sudo apt-get update

# install deps
sudo apt-get install python-setuptools -y
sudo apt-get install python-virtualenv -y
sudo easy_install pip

# setup virtualenv for webapp
PWD=`pwd`
WEBAPP_PATH=$PWD/django
pushd $WEBAPP_PATH
virtualenv .
popd

# install python packages
sudo $WEBAPP_PATH/bin/pip install django gunicorn

# globals
GUNICORN=gunicorn.sh
GUNICORN_TEMPLATE="gunicorn_template.sh"
PROJECT_NAME="helloworld_proj"

# clean up any old conf & scripts
sudo rm $GUNICORN > /dev/null 2>&1
sudo rm /etc/supervisord.conf > /dev/null 2>&1
sudo rm django/$PROJECT_NAME/env_settings.py > /dev/null 2>&1

# setup gunicorn script from template
sed "s#{WEBAPP_PATH}#$WEBAPP_PATH#g" $GUNICORN_TEMPLATE > $GUNICORN
chmod +x $GUNICORN

sed -e "s#{DJANGO_SECRET_KEY}#$DJANGO_SECRET_KEY#g" \
    env_settings_template.py | \
    tee django/$PROJECT_NAME/env_settings.py > /dev/null

# install supervisord
PWD=`pwd`
sed "s#{WEBAPP_PATH}#$PWD#g" supervisord_template.conf | \
    sudo tee /etc/supervisord.conf > /dev/null

sudo mkdir -p /var/log/gunicorn
sudo mkdir -p /var/log/supervisord
sudo $WEBAPP_PATH/bin/pip install supervisor

# start supervisord
sudo $WEBAPP_PATH/bin/supervisorctl stop all
sudo killall -9 supervisord
sudo $WEBAPP_PATH/bin/supervisord -c /etc/supervisord.conf
