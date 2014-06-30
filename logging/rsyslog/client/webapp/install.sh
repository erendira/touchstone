#!/bin/bash

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <RSYSLOG_SERVER_IP>"
    exit 0
fi

RSYSLOG_SERVER_IP=$1
HOSTNAME=`hostname`

sed -e "s#{RSYSLOG_SERVER_IP}#$RSYSLOG_SERVER_IP#g" \
    webstack_template.conf | \
    tee /etc/rsyslog.d/webstack.conf > /dev/null

service rsyslog restart
