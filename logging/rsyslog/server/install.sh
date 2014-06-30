#!/bin/bash

RSYSLOG_PATH="/var/log/logging_stack"
sudo mkdir -p $RSYSLOG_PATH
sudo chown -R syslog:syslog $RSYSLOG_PATH

sudo cp -f ./50-default.conf /etc/rsyslog.d/
sudo cp -f ./rsyslog.conf /etc/
sudo service rsyslog restart
