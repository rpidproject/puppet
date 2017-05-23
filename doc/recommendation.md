# Recommendations for RPID testbed project

## Server provisioning

The services will be provisioned, deployed, and managed using the open-source Puppet tool, including automated provisioning of AWS cloud resources.

## Monitoring

Automated monitoring will be managed by Puppet using the open-source Icinga framework, including:

 * Host availability and uptime
 * Service availability and uptime for all network-available services

## Backups

All data associated with the services will be backed up locally for instant retrieval, and a facility will be provided to copy backup data offsite using the open-source Duplicity tool.

## Configuration data

Site-specific data required for the services will be configured via the Hiera database in Puppet. Sensitive data such as AWS credentials will be encrypted using the open-source GnuPG tool.

## Application deployment

The application components of the testbed (Handle Server, Data Types Registry, and PIT Registry) and their supporting services will be deployed as Linux containers using the open-source Docker framework. This approach is preferred to direct deployment on Linux servers because it:

 * encapsulates all configuration and dependencies within the container
 * decouples the Puppet code from the specific requirements of the application
 * makes it easier to migrate to different OS versions or platforms (for example, a university computing infrastructure)
 * improves reliability of deployments by making it possible to roll back to a previous version of the container
 * provides a path to future scaling and load balancing of the services using a container orchestration system such as Kubernetes
