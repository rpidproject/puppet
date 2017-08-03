# RPID Puppet Repository

The RPID Puppet Repository contains a suite of Puppet 4 manifests that can be used to standup an instance of the RPID Test Bed in an automated, repeatable fashion.

The Puppet Repository can be used to configure instances on Amazon Web Services, on a Vagrant box, or physical machines.  
It will install and configure each of the 4 Test Bed Services:

* Handle Server 
* Data Type Repository (Cordra Implementation)
* Persistent Identifier Types Service API (RPID Extended Implementation)
* Collections Service API (Perseds Manifold Implementation)

It also will install and configure Icina Monitoring services.

The services can be deployed together on a single node or spread across multiple nodes in a network.

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

## Collections Configuration

## PIT Configuration

## Amazon Web Services Orchestration Configuration (Optional)


