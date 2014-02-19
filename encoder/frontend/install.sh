#!/bin/bash

# update apt repos
sudo apt-get update

# install nginx
sudo apt-get install nginx htop -y

# soft link the upstart job files
PWD=`pwd`
sudo cp -f $PWD/encoder /etc/nginx/sites-available/
sudo ln -s -f /etc/nginx/sites-available/encoder /etc/nginx/sites-enabled/encoder

# start nginx
sudo service nginx start
