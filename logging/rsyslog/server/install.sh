#!/bin/bash

sed -i "s/#\$ModLoad imtcp/\$ModLoad imtcp/g" /etc/rsyslog.conf 
sed -i "s/#\$InputTCPServerRun 514/\$InputTCPServerRun 514/g" /etc/rsyslog.conf
service rsyslog restart
