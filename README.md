## Touchstone
Date: 04/08/2014

## Introduction
Touchstone is a collection of projects with the intention of showcasing the following lessons & Rackspace Cloud capabilties:

  * How to architect projects to properly use the current best practices of web development & cloud computing
  * Where one should be decoupling responsibility amongst services to provide the best performance, functionaliy and content delivery with minimal delay & disruption
  * How to properly consume & utilize Rackspace Cloud resources
  * How to organzie & orchestrate the provisioning of cloud infrastructure and leveraging this capability to allow for the self-configuration of web services in the rest of the stack above

## Notes
  * Where applicable, projects will be based on an OpenStack Heat Template file (*.template) using the [HOT format](http://docs.openstack.org/developer/heat/template_guide/hot_guide.html) that self-provisions, installs and configures the project when provided into a Heat environment.
  * There are templates that function for both Rackspace's Public Cloud & Rackspace's Private Cloud
    * On public cloud, it is tailored to consume [Rackspace's Heat Resource Types](http://docs.rackspace.com/orchestration/api/v1/orchestration-devguide/content/GET_resource_type_list_v1__tenant_id__resource_types_Stack_Resources.html#GET_resource_type_list_v1__tenant_id__resource_types_Stack_Resources-Response)
    * On private cloud, it consumes the standard [Heat Resource Types](http://docs.openstack.org/developer/heat/template_guide/openstack.html)
  * Rackspace's Public Cloud Orchestration (aka "Heat") capabilities are currently available via API only
    * [Announcement Blog Post](http://www.rackspace.com/blog/cloud-orchestration-automating-deployments-of-full-stack-configurations/)
    * [Getting Started Guide](http://docs.rackspace.com/orchestration/api/v1/orchestration-getting-started/content/DB_Overview.html)
    * [API](http://docs.rackspace.com/orchestration/api/v1/orchestration-devguide/content/overview.html)
  * Rackspace's Private Cloud Orchestatration (aka "Heat") capabilties are currenlty available via API and Dashboard after modifying the Opscode Chef run list to include 'role[heat-all]'
