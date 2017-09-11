# RPID Puppet Repository

The RPID Puppet Repository contains a suite of [Puppet 4](https://puppet.com/) manifests that can be used to standup an instance of the RPID Test Bed in an automated, repeatable fashion.

The Puppet Repository can be used to configure instances on Amazon Web Services, on a Vagrant box, or physical machines.  
It will install and configure each of the 4 Test Bed Services:

* [Handle Server](http://handle.net)
* Data Type Repository ([Cordra Implementation](http://cordra.org))
* Persistent Identifier Types Service API ([RPID Extended Implementation](https://github.com/rpidproject/RDA-PRAGMA-Data-Service/tree/master/pragmapit-ext))
* Collections Service API ([Perseds Manifold Implementation](https://github.com/rdACollectionsWG/perseids-manifold)

It also will install and configure basic [Icinga](https://www.icinga.com/) Monitoring services.

The services can be deployed together on a single node or spread across multiple nodes in a network.  The core RPID test bed services are all installed in Docker containers to isolate and minimize operating system dependencies.

Configuration variables are managed through Puppet Hiera settings.

The default configuration settings will install all 4 RPID services on a single Node, and the Icinga Monitoring instance on a separate node.  

## Using the Puppet Repository

### Step 1: Prerequisites 
1. Request a Handle Prefix from the Handle System Administrator
2. At least one server on which to host the servers, whether cloud based on a provider like Amazon Web Services (AWS), or a locally hosted machine.  (See below under AWS Quickstart for instructions on how to get started with AWS.)


### Step 2: Personalize the Repository
1. Fork this repository
2. Clone your fork onto a local machine
3. Update the `data/site.yaml` file to use your site specific settings:
    1. Add the shell users their public keys
        * In order to be able to ssh to the instances once they are setup, you need to add your user information to the configuration.  For each user you want to grant ssh access, supply the following in the `users` hash in the `data/site.yaml` file:
        ```
         users:
          'yourloginname':
            comment: 'yourfullname'
            uid: 'youruuidnumber'
            sshkeys:
              - 'your public ssh rsa key'
        ```
    
        e.g
        ```
         users:
           'john':
             comment: 'John Smith'
             uid: '1010'
             sshkeys:
               - 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEA3ATqENg+GWACa2BzeqTdGnJhNoBer8x6pfWkzNzeM8Zx7/2Tf2pl7kHdbsiTXEUawqzXZQtZzt/j3Oya+PZjcRpWNRzprSmd2UxEEPTqDw9LqY5S2B8og/NyzWaIYPsKoatcgC7VgYHplcTbzEhGu8BsoEVBGYu3IRy5RkAcZik= john@example.com'
          ```
        * and then add the login name to the `allow_users` array:
        ```
         allow_users:
          - 'john'
          - 'yourloginname'
        ```
        * if you want to grant sudo access, add the user to the `sudoers` array:
        ```
        sudoers:
          - 'john'
          - 'yourloginname'
        ```
    2. Supply your Handle prefix, the IP Address for the server which will host the services, and your Handle Admin's email address (in order to supply the IP Address you will may to follow "Bootstrap" steps below).
        ```
        site::handle_prefix: 'yourprefixhere'
        site::id_address: 'your ip address here'
        site::admin_email: 'admin email here'
        ```
    3. Add a site-specific admin password for your Cordra instance:
        ```
        cordra:admin_password: 'your cordra admin password'
        ```
    4. Add the ip address for your monitoring server ((in order to supply the IP Address you will may to follow "Bootstrap" steps below)
        ```
        monitor_ips:
         - your.monitor.ip.address.here
        ```
    5. If you your Icinga Monitoring to push notifications to a Slack channel, add your slack webhook url:
        ```
        slack_webhook_url: 'https://hooks.slack.com/services/XXXXXXXXXXXXX'
        ```
4. Commit the updated `site.yaml` changes to your local clone and push to GitHub.

### Step 3: Bootstrap Your Server

#### AWS: Quick Start with Amazon Web Services (via AWS Console)

1. Create an account on Amazon Web Services
2. Create two Elastic IP Addresses (you will need a fixed IP address in order to run the Handle Service and one for your Monitor server) 
3. Create an Open Security Group (firewall will be managed by puppet)
4. Create an new EC2 instance and assign it the first Elastic IP. 
    > Recommended Instance Configuration
    > * Ubuntu 16:04 (ami-cd0f5cb6)
    > * t2 large (2 CPU/8GB RAM)
    > * 25GB root file system
    > * Open Security Group
    > * keypair: create a keypair and download the key file to your local filesystem, making sure the local copy is chmod'd 0600
5. Create an new EC2 instance and assign it the second Elastic IP. 
    > Recommended Instance Configuration
    > * Ubuntu 16:04 (ami-cd0f5cb6)
    > * t2 micro 
    > * Open Security Group
    > * use the keypair created in step 4
6. Be sure to edit the `data/site.yaml` in your cloned fork of the puppet repo to supply your prefix and Server IP Addresses and commit and push these changes to GitHub (see step 3 under "Step 2 Personalize the Repository" above)
7. From the root of your cloned GitHub repo run `scripts/puppify <your forked github repo> <path/to/awskeyfile> <elastic ip> rpid` to setup the main RPID testbed server
8. From the root of your cloned GitHub repo run `scripts/puppify <your forked github repo> <path/to/awskeyfile> <elastic ip> monitor` to setup the monitoring server
   
#### Local Server: Bootstrap a non AWS server
1. Be sure to edit the `data/site.yaml` in your cloned fork of the puppet repo to supply your prefix and Server IP Addresses and commit and push these changes to GitHub (see step 3 under "Step 2 Personalize the Repository" above)
2. scp the bootstrap script to your server, under a user with sudo access
    ```
     scp scripts/bootstrap.sh user@host:/tmp
     ```
3. run the bootstrap script on your server, under a user with sudo access to setup the main RPID testbed server
    ```
    ssh username@host "sudo bash /tmp/bootstrap.sh <url of your puppet repo clone> rpid"
    ```
4. run the bootstrap script on your server, under a user with sudo access to setup the main RPID monitor server
    ```
    ssh username@host "sudo bash /tmp/bootstrap.sh <url of your puppet repo clone> monitor"
    ```
    
### Step 4: Register your Handle Server and Cordra DTR Instances
1. scp a copy of `/docker/run/handle/sitebndl.zip` from bootstrapped server to your local machine and send it to the Handle System Administrator
2. When notified that the Handle is registered you need to update your puppet configuration to start the Cordra Docker Container. This has to be done in a separate step once the Handle Service is available and registered so that Cordra can register itself with the Handle server upon setup.  Edit the `data/site.yaml` file and set `cordra::container_status` to 'present':
    ```
      cordra::container_status: 'present'
    ```
3. Commit the change and push to GitHub. The next time puppet runs on your server (within 10 minutes), the Cordra container will be started and configured.
4. If you want to be able to access the web-based Handle System admin interface, you will need to scp a copy of the admpriv.bin key to your local machine. This can be found on the bootstrapped server in /docker/run/handle.

### Step 5: Verify the Setup

#### Puppet

The puppet repository will be installed on the bootstrapped server in `/etc/puppetlabs/code/environments/production`.

The run-puppet script is configured to run as a root cron job every 10 minutes.

If all expected services are not running immediately after bootstrapping, ssh to the node and run `papply` to verify that puppet runs to completion.

#### RPID Node

The default configuration should result in the following service endpoints:

##### Handle Service

Docker Container: rpid-handle

Public Ports: 8080 (http) and 2641 (tcp and udp)

Shared Data Volume: /docker/run/handle

##### Cordra DTR Service

Docker Container: rpid-cordra

Public Ports: 80 (http), 443 (https), 9000 (tcp), 9001 (ssl)

Shared Data Volume: /docker/run/cordra/data

##### Collections Service

Docker Containers: rpid-manifold, rpid-marmotta, rpid-postgres

Ports: 80 (http), 443 (https), 9000 (tcp), 9001 (ssl)

Shared Data Volume: /docker/run/collections

Public Ports: 5000 (http) 

#### PIT Service

Docker Container: rpid-pit

Public Ports: 8088 (http)

### Monitor Node

The Icinga Monitor node is setup by default with Web checks of the http endpoints of each of the 4 services.  Monitoring alerts will be emailed to the address listed in the `site::admin_email` setting, and, optionally, to the Slack service configured in the `slack_webhook_url` (both found in `site.yaml`). The default username/password for the Icinga Web Interface is set to icinga/g1mmestatus. To change this edit `site_modules/icinga/files/htpasswd.icinga`.

## Advanced Configuration

To add additional monitoring checks on the RPID services, you should edit the templates in `/etc/puppetlabs/code/environments/production/site-modules/icinga/templates`. See the Icinga documentation for instructions on Icinga configuration options.  

The default RPID Puppet setup installs all 4 RPID services on a single node.  Splitting the services across nodes is possible, although may require modifications to the puppet manifests to eliminate cross-service dependencies. Node configuration is defined in `etc/puppetlabs/code/environments/production/data/nodes`. 

Each RPID service offers different service-level configuration options.  These can be found in the `data/common.yaml` file, prefixed by the service groupname.  See the individual service documentation for details on how to use these settings.

The default RPID testbed setup configures the Handle Service to operate as a primary site with multi-primary options disabled. Although the configuration settings for these options are provided in the puppet manifest, modifications to the puppet manifests may be required to fully deploy the Handle service in these alternative modes.


