#!/bin/bash

ELK_SERVER_IP=$1

# Create logs directory
RSYSLOG_PATH="/var/log/logging_stack"
sudo mkdir -p $RSYSLOG_PATH
sudo chown -R syslog:syslog $RSYSLOG_PATH

# Setup rsyslog conf
sudo cp -f ./50-default.conf /etc/rsyslog.d/
sudo cp -f ./rsyslog.conf /etc/

# setup logstash send off
sed -e "s#{ELK_SERVER_IP}#$ELK_SERVER_IP#g" \
    logging_stack_template.conf | \
    tee /etc/rsyslog.d/logging_stack.conf > /dev/null

sudo service rsyslog restart
