#!/bin/bash

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <WEBAPP_IP>"
    echo "Set servers in update.sh"
    exit 0
fi

WEBAPP_IP=$1
SERVERS_INFO="\n\tserver $WEBAPP_IP:8000;\n\t#server backend2.example.com;\n"
sed "s@{SERVERS_INFO}@$SERVERS_INFO@g" /etc/nginx/sites-available/encoder | \
    sudo tee /etc/nginx/sites-available/encoder > /dev/null

# update nginx conf file
sudo service nginx reload
sudo service nginx start
