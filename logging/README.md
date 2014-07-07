# Project Logging

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
  * When the user visits the webapp, they will be presented with a simple Hello World page which displays the hostname of the webapp server that fulfilled the request
  * Behind the scenes, the Cloud Load Balancer is cycling through 2 frontend nodes tasked with receiving HTTP requests
  * The frontend nodes each manage a pair of 2 webapp servers that it cycles through when forwarding the incoming requests
  * The webapp then renders a page with the hostname of the server that is processing the request to demonstrate the redundancy taking place
  * The Cloud Load Balancer also monitors the health of the frontend + webapp combo by insuring that these nodes in the load balancing layer are not erroring out with HTTP status codes of 5XX - if they do, they are pulled from the load balancing pool
  * The frontend & webapp nodes are simultaneously feeding all of their raw, noteworthy logs (i.e. Nginx + Gunicorn/Django) to an rsyslog server which functions as a central log aggregate
  * The rsyslog server then passes the raw logs to an ELK stack (Elasticsearch + Logstash + Kibana) which filters, stores and provides visualization for the logs based on some basic logic releveant to the logs collected
    * i.e.
      * Logstash filters the Nginx & Gunicorn access-logs to parse relevant request header information
      * Logstash then passes the filtered logs to Elasticsearch, where they are stored
      * Kibana communicates with Elasticsearch to provide a visualization layer to view the parsed logs
  * If one wishes, you can easily increase the number of frontend & webapp nodes used by modifying the heat template to make the initial architecture even more redundant 

## Rackspace Cloud Services Used
  * Cloud Servers
  * Cloud Load Balancers
  * Service Network
  * Cloud Orchestration (OpenStack Heat)

## Architecture
  * Format: Web Architecture
    * **Load Balancer**: Client Load Balancer (Cloud Load Balancer / HAProxy)
    * **Front Ends**: Client HTTP Server (Nginx)
    * **Middle Layers**: Webapp (Gunicorn + Django)
    * **Log Server**: Log Aggregator (Rsyslog)
    * **Analysis Stack**: Logstash + Elasticsearch + Kibana
    <div><img src="https://raw.github.com/metral/touchstone/master/logging/extras/logging.jpg" height="600" width="700"></div>
