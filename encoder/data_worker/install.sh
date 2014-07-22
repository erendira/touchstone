#!/bin/bash

EXPECTEDARGS=4
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <RAX_USERNAME> <RAX_APIKEY> <DATA_MASTER_IP> <MYSQL_PASS> <USE_SNET> <EMAIL>"
    exit 0
fi

RAX_USERNAME=$1
RAX_APIKEY=$2
DATA_MASTER_IP=$3
MYSQL_PASS=$4
USE_SNET=$5
EMAIL=$6
MYSQL_DB="encoder"
MYSQL_USER="rax"
MYSQL_PORT="3306"
HOSTNAME=`hostname`
IP_ADDR=`hostname -I | cut -d " " -f1`

# setup & install mysql client
sudo apt-get update
sudo apt-get install mysql-client-core-5.5 -y

# install easy_install, pip, gearman api
sudo apt-get install python-setuptools python-mysqldb -y
sudo easy_install pip
sudo pip install gearman pyrax
sudo pip install --upgrade pyrax
sudo pip install --upgrade six==1.7.0 requests==2.2.1

# install ffmpeg & deps
sudo apt-get install python-sphinx -y

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
    #wget http://johnvansickle.com/ffmpeg/releases/ffmpeg-2.1.3-64bit-static.tar.bz2
    tar xvf ffmpeg*64bit*
    mv ffmpeg*/ff* /usr/local/bin/
    mv ffmpeg*/qt* /usr/local/bin/
else
    #wget http://ffmpeg.gusari.org/static/32bit/ffmpeg.static.32bit.2014-03-01.tar.gz
    tar xvf ffmpeg*32bit*
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


# Monitoring as a Service setup

# raxmon creds for RAX
sudo pip install rackspace-monitoring-cli
(cat | tee ~/.raxrc) << EOF
[credentials]
username = $RAX_USERNAME
api_key = $RAX_APIKEY
EOF

# Delete any preexisting entities w/ same name
echo ""
array=( `raxmon-entities-list | grep $HOSTNAME | cut -d " " -f2 | cut -d "=" -f2` )
for i in "${array[@]}"
do
   echo "Attempting deletion of existing entity with same label ($HOSTNAME): $i"
   raxmon-entities-delete --id $i 2>/dev/null
done

ENTITY_ID=""
echo ""
if [ "`raxmon-entities-list | grep $HOSTNAME`" == "" ] ; then
    ENTITY_ID=`raxmon-entities-create --label $HOSTNAME --ip-addresses="alias=$IP_ADDR" | cut -d " " -f4`
    echo "Created new entity: $ENTITY_ID"
else
    ENTITY_ID=`raxmon-entities-list | grep $HOSTNAME | cut -d " " -f2 | cut -d "=" -f2 | head -n1`
    echo "Using existing entity with same label ($HOSTNAME): $ENTITY_ID"
fi
echo ""

# Install agent
echo "deb http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-13.10-x86_64 cloudmonitoring main" >> /etc/apt/sources.list.d/rackspace-monitoring-agent.list
curl https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc | sudo apt-key add - 

sudo apt-get update
sudo apt-get install rackspace-monitoring-agent

echo 1 | rackspace-monitoring-agent --setup --username $RAX_USERNAME --apikey $RAX_APIKEY
service rackspace-monitoring-agent start

# Create checks, notifications, alerts
CHECK_ID=`raxmon-checks-create --entity-id=$ENTITY_ID --type=agent.load_average | cut -d " " -f4`
echo "New check created: $CHECK_ID"

NOTIFICATIONS_ID=`raxmon-notifications-create --label example-email --type email --details="address=$EMAIL" | cut -d " " -f4`
echo "New notification created: $NOTIFICATIONS_ID"

PLAN_ID=`raxmon-notification-plans-create --label notification_plan_1 --critical-state $NOTIFICATIONS_ID --warning-state $NOTIFICATIONS_ID --ok-state $NOTIFICATIONS_ID | cut -d " " -f4`
echo "New notification plan created: $PLAN_ID"

ALARM_ID=`raxmon-alarms-create --check-id=$CHECK_ID --criteria "if (metric[\"1m\"] >= 0.7) { return WARNING}" --notification-plan $PLAN_ID --entity-id $ENTITY_ID | cut -d " " -f4`
echo "New alarm created: $ALARM_ID"
