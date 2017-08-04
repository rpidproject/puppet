# RPID Puppet Repository

The RPID Puppet Repository contains a suite of Puppet 4 manifests that can be used to standup an instance of the RPID Test Bed in an automated, repeatable fashion.

The Puppet Repository can be used to configure instances on Amazon Web Services, on a Vagrant box, or physical machines.  
It will install and configure each of the 4 Test Bed Services:

* Handle Server 
* Data Type Repository (Cordra Implementation)
* Persistent Identifier Types Service API (RPID Extended Implementation)
* Collections Service API (Perseds Manifold Implementation)

It also will install and configure Icina Monitoring services.

The services can be deployed together on a single node or spread across multiple nodes in a network.  The core RPID test bed services are all installed in Docker containers to isolate and minimize operating system dependencies.

Configuration variables are managed through Puppet Hiera settings.

The default configuration settings will install all 4 RPID services on a single Node, and the Icinga Monitoring instance on a separate node.  

## Using the Puppet Repository

### Step 1: Prerequisites 
1. Request a Handle Prefix from the Handle System Administrator
2. At least one server on which to host the servers, whether cloud based on a provider like Amazon Web Services (AWS), a Vagrant box, or a locally hosted machine.  (See below under AWS Quickstart for instructions on how to get started with AWS.)

### Step 2: Personalize the Repository
1. Fork this repository
2. Clone your fork onto a local machine
3. Add the shell users their public keys to the `data/common.yaml` file
    * In order to be able to ssh to the instances once they are setup, you need to add your user information to the configuration.  For each user you want to grant ssh access, supply the following in the `users` hash in the `data/common.yaml` file:
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
4. Edit the data/common.yaml in your cloned fork of the puppet repo to supply your Handle prefix, the IP Address for the server which will host the services, and your Handle Admin's email address
    ```
    site::handle_prefix: 'yourprefixhere'
    handle::config:
      server:
        public_address: 'youripaddresshere'
        admin_email: 'youremailhere'
    ```
5. Commit these changes to your local clone and push to GitHub.

### Step 3: Bootstrap Your Server

#### AWS: Quick Start with Amazon Web Services (via AWS Console)

1. Create an account on Amazon Web Services
2. Create an Elastic IP Address (you will need a fixed IP address in order to run the Handle Service) 
3. Create an Open Security Group (firewall will be managed by puppet)
4. Create an new EC2 instance and assign it the Elastic IP. 
    > Recommended Instance Configuration
    > * Ubuntu 16:04 (ami-cd0f5cb6)
    > * t2 large (2 CPU/8GB RAM)
    > * 25GB root file system
    > * Open Security Group
    > * keypair: create one named rpid and copy the rpid.pem to the parent directory of your clone of the puppet repo fork (make sure the local copy is chmod'd 0600)
5. Be sure to edit the data/common.yaml in your cloned fork of the puppet repo to supply your prefix and Server IP Address and commit and push these changes to GitHub (see step 4 under "Step 2 Personalize the Repository" above)
6. run `script/puppify <your forked github repo> <elastic ip> rpid`
   
#### Local Server: Bootstrap a non AWS server
5. Be usre to edit the data/common.yaml in your cloned fork of the puppet repo to supply your prefix and Server IP Address and commit and push these changes to GitHub (see step 4 under "Step 2 Personalize the Repository" above)
6. scp the bootstrap script to your server, under a user with sudo access
    ```
     scp scripts/bootstrap.sh user@host:/tmp
     ```
7. run the bootstrap script on your server, under a user with sudo access
    ```
    ssh username@host "sudo bash /tmp/bootstrap.sh <url of your puppet repo clone> rpid"
    ```
    
#### Local Vagrant: Provision a Vagrant Virtual Box

### Step 4: Register your Handle Server and Cordra DTR Instances
1. scp a copy of /docker/run/handle/sitebndl.zip from bootstrapped server to your local machine and send it to the Handle System Administrator
2. When notified that the Handle is registered you need to update your puppet configuration to start the Cordra Docker Container. This has to be done in a separate step once the Handle Service is available and registered so that Cordra can register itself with the Handle server upon setup.  Edit the `data/common.yaml` file and set 'cordra::container_status' to 'present':
    ```
      cordra::container_status: 'present'
    ```
3. Commit the change and push to GitHub. The next time puppet runs on your server (within 10 minutes), the Cordra container will be started and configured.
4. If you want to be able to access the web-based Handle System admin interface, you will need to scp a copy of the admpriv.bin key to your local machine. This can be found on the bootstrapped server in /docker/run/handle.

### Step 5: Verify the Setup

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
TBD

## Advanced Configuration

### Node/Site Configuration


### Icinga Monitoring


To add Icinga monitoring:

1. Create a EC2 second instance in AWS (Recommended AMI: TBD). Use the same rpid.pem keypair as before.
2. run script/puppify <instance ip> monitor

### Handle Service Configuration

```
  handle::handle_tag: 'latest'
  handle::config:
    server:
      primarysite: true
      multiprimary: false
      servername: 'RPID AWS Handle Server'
      listen_address: '0.0.0.0' 
      public_address: "%{alias('aws::ips.build')}"
      assigned_prefix: "%{alias('site::handle_prefix')}"
      admin_idx: "300:0.NA"
      admin_email: 'bridget.almas@tufts.edu'
      admin_org_name: 'RPID'
      log_rotation_frequency: 'Monthly'
      template_delimiter: '|'
    ports:
      http: 8000
      tcp: 2641
      udp: 2641
    host_ports:
      http: 8000
      tcp: 2641
      udp: 2641
  handle::volume_mount: '/handleserver'
  handle::download_url: 'http://www.handle.net/hnr-source/hsj-8.1.1.tar.gz'
  handle::user: 'handle'
  handle::docker_base: 'openjdk:8u131-jre-alpine'
```

### DTR (Cordra) Configuration

```
  cordra::admin_password: 'dummy'
  cordra::download_url: 'https://www.cordra.org/unconfiguredInstanceDownload'
  cordra::docker_base: 'openjdk:8u131-jre-alpine'
  cordra::cordra_tag: 'latest'
  cordra::config:
    server:
      serverid: '1'
      servername: 'RPID AWS Cordra Server'
      admin_handle: "%{alias('site::handle_config.server.admin_id')}"
      listen_address: '0.0.0.0'
      redirect_stderr: 'no'
      enable_pull_replication: 'no'
      log_accesses: 'yes'
      log_save_interval: 'Monthly'
      dtr_prefix: '1'
      assigned_prefix: "%{lookup('site::handle_prefix')}/repo"
      register_handles: 'yes'
    ports:
      https: 443
      http: 80
      server: 9000
      ssl: 9001
    host_ports:
      https: 443
      http: 80
      server: 9000
      ssl: 9001
```

### Collections Configuration

```
  collections::manifold::docker_base: 'ubuntu:16.04'
  collections::manifold::repos: 'https://github.com/RDACollectionsWG/perseids-manifold'
  collections::manifold::revision: 'master'
  collections::manifold::host_port: 5000
  collections::manifold::container_port: 5000
  collections::manifold::tag: 'latest'
  collections::manifold::startup_timeout: 60
  collections::marmotta::host_port: 8080
  collections::marmotta::docker_base: 'tomcat:7.0.79-jre8-alpine'
  collections::marmotta::download_url: 'http://mirrors.gigenet.com/apache/marmotta/3.3.0/apache-marmotta-3.3.0-webapp.zip'
  collections::marmotta::tag: 'latest'
  collections::postgres::host_port: 5432
  collections::postgres::db: 'marmotta'
  collections::postgres::user: 'marmotta'
  collections::postgres::password: 'postgreschangeme'
  collections::postgres::tag: '9.4.12-alpine'
  ```
  
### PIT Configuration

### Using Encrypted Secrets 

### Using Amazon Web Services Orchestration


