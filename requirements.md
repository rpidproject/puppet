# RPID Test Bed Component and Roles

## Handle Server
1. Manages and resolves Handles assigned to one or more locally managed prefixes
2. May be setup in one of 3 ways:
  * as a single primary server (accepts administrative requests to register new handles, and resolves handles)
  * as a mirror server (which does not accept administrative requests for new handles, but mirrors and resolves handles managed by the primary server)
  * as a primary in a multiple primary setup (accepts administrative requests to register new handles, and mirrors and resolves handles managed by itself and one or more other primary servers)
3. May optionally be configured as a HTTP to Handle Proxy, resolving local handles vi HTTP requests.

For a detailed discussion of the Handle Server architecture, see the [Technical Manual](http://hdl.handle.net/20.1000/105)

## Data Types Registry (Cordra Implementation)
1. Manages and resolves machine-actionable data type records 
2. Delegates to  a Handle Server to register PIDs for the data type records
   * Handle Server may be the global handle server or a local handle server  

See also the [Cordra Technical Manual](https://cordra.org/TechnicalManual-1.0.7.pdf)

## PIT Registry/API Service
1. Provides a uniform machine-actionable API for Creating and Reading PID records
2. Sits in front of the Handle Server to provide a non-Handle specific way for clients to request and read PID records

See the [RDA PIT Recommentation](https://dx.doi.org/10.15497/FDAA09D5-5ED0-403D-B97A-2675E1EBE786)

# Goals for the Puppet Solution

Enable unassisted, repeatable, beginning-to-end installation and configuration of the core RPID testbed components (Handle Server, Data Types Registry, and PIT Registry). 

The solution should meet the following requirements.
1. Work on at least AWS as a cloud provider
    * keeping to a minimum as much as possible any specific dependence on AWS-specific cloud functionality
2. Be reusable on on university infrastructures
3. Install and configure all testbed components
4. Install and configure monitoring jobs for all testbed components (using an open source monitoring solution)
5. Install and configure backup jobs for all local data (using an open source backup solution)
6. Additionally, for AWS only, provisions all supporting cloud infrastructure resources (servers, volumes, cname records, etc.)
7. Allow for configuration of all variables specific to a deployment including:
      * For the Handle Server component
        * Registered handle prefix(es)
        * Public and Private Keys for cross server communications
        * Role (Single Primary, Mirror, Multiple Primary)
        * For a mirror setup, location of the primary 
        * Certificates for API Authentication
        * Database configuration (host, port, credentials)
      * For the DTR components
        * Location of the Handle Server 
        * Handle Prefix
        * Database configuration (host, port, credentials)
        * JSON Schemas
      * For the PIT component
        * Location of the Handle Server 
      * For all components
        * hostnames
        * ports 
        * users
        * OS-specific nuances
      * For the AWS deployment 
        * AWS account keys
        * Resource provisioning variables (e.g. base images, CPU, RAM and Disk Space requirements, firewall setup, etc.)

  
  




