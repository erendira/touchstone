# Project Encoder

Date: 03/13/2014

## Usage
```
heat stack-create encoder \
--parameters="rax_username=$OS_USERNAME;rax_apikey=$OS_PASSWORD;branch=master" \
-u "https://raw.github.com/metral/touchstone/master/encoder/encoder.template"
```

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
