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

## Quick Start with Amazon Web Services (via AWS Console)

1. Clone this repository
2. Create an account on Amazon Web Services
3. Create an Elastic IP Address (you will need a fixed IP address in order to run the Handle Service) 
4. Create an new EC2 instance (Recommended AMI: TBD) and assign it the Elastic IP. In doing so, create a new keypair named rpid.pem and copy this key to the root directory of your local clone of the repository
5. Request a Handle Prefix from the Handle System Administrator
6. Supply your prefix and Server IP Address in in data/common.yaml :
    ```
    site::handle_prefix: 'yourprefixhere'
    handle::config:
      server:
        public_address: '<your elastic ip address here>'
    ```
7. run script/puppify <elastic ip> rpid
8. scp a copy of /docker/run/handle/sitebndl.zip from the EC2 instance to your local machine and send it to the Handle System Administrator
9. When notified that the Handle is registred, ssh to the EC2 instance and register your Cordra repository with your local handle server by running:
   ```/docker/run/cordra/configure.sh```
   

## Node/Site Configuration

## Handle Service Configuration

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

## DTR (Cordra) Configuration

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

## Collections Configuration

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
  
## PIT Configuration

## Icinga Configuration 

## Encrypted Secrets (Optional)

## Amazon Web Services Orchestration Configuration (Optional)


