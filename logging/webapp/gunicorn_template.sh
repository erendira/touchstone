#!/bin/bash

set -e
NUM_WORKERS="$(((`cat /proc/cpuinfo | grep processor | wc -l` * 2) + 1))"
USER=`id -un`
GROUP=`id -gn`
cd {WEBAPP_PATH}
source bin/activate
exec gunicorn_django -b {BIND_HOST} -w $NUM_WORKERS --timeout=3600 --user=$USER --group=$GROUP --log-level=debug --error-logfile=- --access-logfile=-
