#!/bin/bash

# Source creds
source ~/openrc
export DEFAULT_MASTER_FLAVOR=`nova flavor-show m1.medium | grep id | awk '{print $4}'`
export DEFAULT_WORKER_FLAVOR=`nova flavor-show m1.medium | grep id | awk '{print $4}'`

# Install & configure Savanna
cd ~/
sudo apt-get install python-setuptools python-virtualenv python-dev -y

virtualenv savanna-venv
savanna-venv/bin/pip install savanna
mkdir savanna-venv/etc
cp savanna-venv/share/savanna/savanna.conf.sample savanna-venv/etc/savanna.conf

sed -i "2i\os_auth_host=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f1`\nos_auth_port=`echo $OS_AUTH_URL | cut -d "/" -f3 | cut -d ":" -f2`\nos_admin_username=$OS_USERNAME\nos_admin_password=$OS_PASSWORD\nos_admin_tenant_name=$OS_TENANT_NAME\ndebug=true\nuse_floating_ips=false" savanna-venv/etc/savanna.conf

# To send REST requests to Savanna API, use httpie (optional)
sudo pip install httpie

# Start Savanna API Server
savanna-venv/bin/python savanna-venv/bin/savanna-api --config-file savanna-venv/etc/savanna.conf > ~/savanna_api_server.log 2>&1 &
sleep 5

# Create Glance image used for Hadoop Cluster
TOKEN=`keystone token-get | grep id | grep -v user_id | awk '{print $4}'`
export AUTH_TOKEN=`echo $TOKEN | cut -d ' ' -f1`
export TENANT_ID=`echo $TOKEN | cut -d ' ' -f2`

# TODO: put sahara file on cloud files to be faster d/l than from mirantis
#wget http://sahara-files.mirantis.com/sahara-icehouse-vanilla-1.2.1-ubuntu-13.10.qcow2
glance image-create --name=sahara-0.3-icehouse-vanilla-hadoop-1.2.1-ubuntu-13.10 --disk-format=qcow2 --container-format=bare < ./sahara-icehouse-vanilla-1.2.1-ubuntu-13.10.qcow2
export IMAGE_ID=`glance image-list | grep sahara | awk '{print $2}'`
export IMAGE_USER="ubuntu"

# Register Glance image with Savanna
# TODO: get IP addr of br-eth2
export SAVANNA_URL="http://10.127.26.132:8386/v1.0/$TENANT_ID"
http POST $SAVANNA_URL/images/$IMAGE_ID X-Auth-Token:$AUTH_TOKEN username=ubuntu
http $SAVANNA_URL/images/$IMAGE_ID/tag X-Auth-Token:$AUTH_TOKEN tags:='["vanilla", "1.2.1", "ubuntu"]'

# Create Hadoop nodegroup templates & send to Savanna
mkdir ~/nodegroup_templates
cd ~/nodegroup_templates

(cat | tee ng_master_template_create.json) << EOF
{
    "name": "test-master-tmpl",
    "flavor_id": "$DEFAULT_MASTER_FLAVOR",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["jobtracker", "namenode"]
}
EOF

(cat | tee ng_worker_template_create.json) << EOF
{
    "name": "test-worker-tmpl",
    "flavor_id": "$DEFAULT_WORKER_FLAVOR",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_processes": ["tasktracker", "datanode"]
}
EOF

OUTPUT=`http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ng_master_template_create.json`
MASTER="$OUTPUT"
echo $MASTER
MASTER_TEMPLATE_ID=`echo $MASTER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $MASTER_TEMPLATE_ID

OUTPUT=`http $SAVANNA_URL/node-group-templates X-Auth-Token:$AUTH_TOKEN < ng_worker_template_create.json`
WORKER="$OUTPUT"
echo $WORKER
WORKER_TEMPLATE_ID=`echo $WORKER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node_group_template"]["id"]'`
echo $WORKER_TEMPLATE_ID

# Create Hadoop cluster template & send to Savanna
(cat | tee cluster_template_create.json) << EOF
{
    "name": "demo-cluster-template",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "node_groups": [
        {
            "name": "master",
            "node_group_template_id": "$MASTER_TEMPLATE_ID",
            "count": 1
        },
        {
            "name": "workers",
            "node_group_template_id": "$WORKER_TEMPLATE_ID",
            "count": 2
        }
    ]
}
EOF

OUTPUT=`http $SAVANNA_URL/cluster-templates X-Auth-Token:$AUTH_TOKEN < cluster_template_create.json`
CLUSTER="$OUTPUT"
echo $CLUSTER
CLUSTER_TEMPLATE_ID=`echo $CLUSTER | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["cluster_template"]["id"]'`
echo $CLUSTER_TEMPLATE_ID

# Create Hadoop cluster
(cat | tee cluster_create.json) << EOF
{
    "name": "cluster-1",
    "plugin_name": "vanilla",
    "hadoop_version": "1.2.1",
    "cluster_template_id" : "$CLUSTER_TEMPLATE_ID",
    "user_keypair_id": "adminKey",
    "default_image_id": "$IMAGE_ID"
}
EOF

http $SAVANNA_URL/clusters X-Auth-Token:$AUTH_TOKEN < cluster_create.json

sleep 30

MASTER_IP=`nova show cluster-1-master-001 | grep "public\ network" | awk '{print $5}'`
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet $IMAGE_USER@$MASTER_IP "sudo chmod 777 /usr/share/hadoop ; sudo sed -i 's/128m/2048m/g' /etc/hadoop/hadoop-env.sh"

# Usage example
echo ""
echo "Usage - Create a Hadoop job on the master node"
echo "----------------------------------------------"
echo "$ ssh ubuntu@172.16.0.2"
echo "$ sudo su hadoop"
echo "$ cd /usr/share/hadoop"
echo "$ hadoop jar hadoop-examples-1.2.1.jar pi 10 100"
