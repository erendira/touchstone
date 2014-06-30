#!/bin/bash

sudo mkdir -p /var/log/logging_stack
sudo cp -f ./50-default.conf /etc/rsyslog.d/
sudo cp -f ./rsyslog.conf /etc/
sudo service rsyslog restart
