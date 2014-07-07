# Project Encoder

Date: 07/07/2014

## Usage

**Rackspace Public Cloud**

```
heat stack-create logging \
--parameters="branch=master" \
-u "https://raw.github.com/metral/touchstone/master/logging/public_cloud.yaml
```

## Synopsis
In this project, we will be setting up a redundant hello world webapp that
feeds into a log aggregator and then filters, stores & allows for the
visulization of the logs.

## Webapp Flow
 
## Rackspace Cloud Services Used
  * Cloud Servers
  * Cloud Load Balancers
  * Service Network
  * Orchestration (OpenStack Heat)

## Architecture
  * Format: Web Architecture
    * **Load Balancer**: Client Load Balancer (Cloud Load Balancer / HAProxy)
    * **Front Ends**: Client HTTP Server (Nginx)
    * **Middle Layers**: Webapp (Gunicorn + Django)
    * **Log Server**: Log Aggregator (Rsyslog)
    * **Analysis Stack**: Logstash + Elasticsearch + Kibana
    <div><img src="https://raw.github.com/metral/touchstone/master/logging/extras/logging.jpg" height="600" width="700"></div>
