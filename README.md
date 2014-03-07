## Touchstone
Date: 03/07/2014

## Introduction
Touchstone is a collection of projects with the intention of showcasing the following lessons & Rackspace Cloud capabilties:

  * How to architect projects to properly use the current best practices of web development & cloud computing
  * Where one should be decoupling responsibility amongst services to provide the best performance, functionaliy and content delivery with minimal delay & disruption
  * How to properly consume & utilize Rackspace Cloud resources
  * How to organzie & orchestrate the provisioning of cloud infrastructure and leveraging this capability to allow for the self-configuration of web services in the rest of the stack above

## Notes
  * Each project contains an OpenStack Heat Template file (*.template) that self-provisions, installs and configures the project
  * Currently, the Heat template file only functions on Rackspace's Public Cloud and is tailored to consume [Rackspace's Heat Resource Types](http://andersonvom.github.io/openstack_docs/template_guide/contrib.html)
  * Rackspace's Heat capabilities are currently limited to **internal usage only** as this service is currently not publicly accessible yet
