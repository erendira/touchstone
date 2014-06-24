#!/bin/bash

# update apt repos
sudo apt-get update

# install nginx
sudo apt-get install nginx -y

# soft link the upstart job files
PWD=`pwd`
sudo cp -f $PWD/logging /etc/nginx/sites-available/
sudo ln -s -f /etc/nginx/sites-available/logging /etc/nginx/sites-enabled/logging
sudo rm /etc/nginx/sites-enabled/default

# start nginx
sudo service nginx start
