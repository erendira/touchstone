#!/bin/bash

EXPECTEDARGS=2
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <WEBAPP_IP1> <WEBAPP_IP2>"
    exit 0
fi

WEBAPP_IP1=$1
WEBAPP_IP2=$2

SERVERS_INFO="\n\tserver $WEBAPP_IP1:8000;\n\tserver $WEBAPP_IP2:8000;\n"
sed "s@{SERVERS_INFO}@$SERVERS_INFO@g" /etc/nginx/sites-available/logging | \
    sudo tee /etc/nginx/sites-available/logging > /dev/null

# update nginx conf file
sudo service nginx reload
sudo service nginx start
