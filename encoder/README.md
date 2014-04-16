# Project Encoder

Date: 03/18/2014

## Usage

**Rackspace Public Cloud**

```
heat stack-create encoder \
--parameters="rax_username=$OS_USERNAME;rax_apikey=$OS_PASSWORD;email=<EMAIL_ADDRESS>;branch=master;use_snet=true" \
-u "https://raw.github.com/metral/touchstone/master/encoder/public_cloud_encoder.template"
```

**Rackspace Private Cloud**

```
heat stack-create encoder \
--parameters="rax_username=$OS_USERNAME;rax_apikey=$OS_PASSWORD;email=<EMAIL_ADDRESS>;branch=master;use_snet=false" \
-u "https://raw.github.com/metral/touchstone/master/encoder/private_cloud_encoder.template"
```

***Note:*** Parameters "rax\_username" & "rax\_apikey" refer to the Rackspace Public Cloud Username & API Key as all media files are stored on Rackspace Cloud Files in the Public Cloud. Parameter "email" refers to an email address you would like to register to receive notifications made available by the integrated Monitoring as a Service capabilites via [Rackspace Cloud Intelligence](https://intelligence.rackspace.com/overview?query=entityIds~enTlzdDiyh!duration~86400000!points~500!mode~overview) and the [Getting Started with Rackspace Monitoring Guide](http://www.rackspace.com/knowledge_center/article/getting-started-with-rackspace-monitoring-cli) to watch the data_worker node's CPU load average as created in its [install.sh](https://github.com/metral/touchstone/blob/master/encoder/data_worker/install.sh)

## Synopsis
In this project, we will be setting up a webapp that encodes a provided video file into the following formats:
  * [AVI](http://en.wikipedia.org/wiki/Audio_Video_Interleave)
  * [MKV](http://en.wikipedia.org/wiki/Matroska)
  * [OGG](http://en.wikipedia.org/wiki/Ogg)
  * [WEBM](http://en.wikipedia.org/wiki/WebM)

## Webapp Flow
  * When the user visits the webapp, they are presented with the ability to upload a video file
  * The user will select a video file already available & stored locally on their computer
  * The video file will then be uploaded to the object storage service provided by Rackspace Cloud Files
  * Upon a successful upload, the webapp will create an encoding job request that will be entered into the MySQL database for tracking and passed off to the Gearman Job Server for processing
  * Once the Gearman Job Server receives the job request, it will locate an available Gearman Job Worker to perform the encoding job
  * The Gearman Job Worker then utilizes the [FFmpeg](http://www.ffmpeg.org/) encoding library to convert the user's video into the available formats
  * Once the video has been encoded into each format by the Gearman Job Worker, it will upload the encoding to Rackspace Cloud Files
  * All the while, the webapp will be providing a means to view the status of the encoding job as well as publicly accessible URL's of each encoding format as they become available for consumption
 
## Rackspace Cloud Services Used
  * Cloud Servers
  * Cloud Files
  * Service Network
  * Orchestration (OpenStack Heat)

## Architecture
  * Format: 3-Tier Web Architecture
    * **Front End**: Client HTTP Server (Nginx)
    * **Middle**: Webapp (Gunicorn + Django)
    * **Back End**: Data Master (Gearman Job Server + MySQL DB) & Data Worker (Gearman Job Worker)
    <div><img src="https://raw.github.com/metral/touchstone/master/encoder/extras/encoder.jpg" height="600" width="700"></div>
