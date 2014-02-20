#!/bin/bash

set -e
LOGFILE=/var/log/gunicorn/webapp.log
LOGDIR=$(dirname $LOGFILE)
NUM_WORKERS="$(((`cat /proc/cpuinfo | grep processor | wc -l` * 2) + 1))"
USER=`id -un`
GROUP=`id -gn`
cd {WEBAPP_PATH}
source bin/activate
test -d $LOGDIR || mkdir -p $LOGDIR
exec /usr/local/bin/gunicorn_django --debug -b 0.0.0.0 -w $NUM_WORKERS --timeout=3600 --user=$USER --group=$GROUP --log-level=debug --log-file=$LOGFILE 2>>$LOGFILE
