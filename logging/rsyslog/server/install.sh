#!/bin/bash

sudo cp -f ./50-default.conf /etc/rsyslog.d/
sudo cp -f ./rsyslog.conf /etc/
sudo service rsyslog restart
