#!/bin/bash

ELK_LOGS="/var/log/elk"
mkdir -p $ELK_LOGS

# Run elasticsearch
/opt/elasticsearch*/bin/elasticsearch > $ELK_LOGS/elasticsearch.log 2>&1 & 
sleep 10

# Run logstash
curl -XDELETE "http://localhost:9200/_all" ; /opt/logstash*/bin/logstash -f {CONF_PATH}/confs > $ELK_LOGS/logstash.log 2>&1 & 
sleep 3

# Run kibana
pushd /opt/kibana* > /dev/null 2>&1
python -m SimpleHTTPServer > $ELK_LOGS/kibana.log 2>&1 &
popd > /dev/null 2>&1
