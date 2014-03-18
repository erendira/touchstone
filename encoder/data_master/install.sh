#!/bin/bash

EXPECTEDARGS=1
if [ $# -lt $EXPECTEDARGS ]; then
    echo "Usage: $0 <MYSQL_PASS>"
    exit 0
fi

# setup & install mysql
sudo apt-get update

MYSQL_DB="encoder"
MYSQL_USER="rax"
MYSQL_PASS=$1

sudo debconf-set-selections \
    <<< "mysql-server-5.0 mysql-server/root_password password $MYSQL_PASS"
sudo debconf-set-selections \
    <<< "mysql-server-5.0 mysql-server/root_password_again password $MYSQL_PASS"
sudo apt-get install mysql-server -y

# Change bind addr
sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
sudo service mysql restart

# create webapp sql db & user
mysql -uroot -p$MYSQL_PASS << EOF
CREATE DATABASE $MYSQL_DB; 
GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO 
    $MYSQL_USER@'%' IDENTIFIED BY '$MYSQL_PASS';
GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO 
    $MYSQL_USER@localhost IDENTIFIED BY '$MYSQL_PASS';
EOF

echo
echo "#################################################"
echo "MySQL User: root"
echo "MySQL Root Password: $MYSQL_PASS"
echo "------------------------------------------------"
echo "MySQL DB: $MYSQL_DB"
echo "MySQL User: $MYSQL_USER"
echo "MySQL Password: $MYSQL_PASS"
echo "#################################################"


# install gearman
sudo apt-get install gearman-job-server -y
