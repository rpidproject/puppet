Deployment comments from Suchitra Manepalli, who built an automated configuration/deployment setup a few months ago involving Cordra and Handle Service. She didn’t use puppet but something similar (a combination of Vagabond and something else). She will be out of the country for a few weeks, working intermittently (as of 11 May 2017) but will respond to email at smanepalli@cnri.reston.va.us

Cordra:

- Cordra can be deployed on a single machine or can be turned into a front for distributed storage and indexing infrastructure. I assume RPID will be content, at least initially, with just a single machine deployment. In that case, RPID should pre-create a config.dct template that gets populated at runtime using variables that are supplied with a specific run. Those variables include IP addresses, ports, directory paths, and passwords.
- Cordra can be deployed as a standalone application or as a web-app within Tomcat. We found bottlenecks if Cordra is used standalone.
- If Tomcat is used, and HTTPS access is preferred/ required, then Tomcat documentation for configuring web certificates should be followed. If standalone Cordra is used, then web certificates should be specified in config.dct (I think).
- Cordra is schema controlled. Schemas should be uploaded to Cordra once the instance is up. By upload, I mean register schema digital objects using the Cordra API. I assume the schemas are data-type record specific JSONs.

Handle Server:

- The main catch with the Handle server setup is that we cannot fully automate it. Public keys and other details generated during the setup will need to be sent to hdladmin out of band for their recording in the prefix record. And of course a prefix or prefixes need to be requested and get allotted prior to running the provisioning.
- hdl-keygen command should be run for generating keypairs. There are multiple keypairs associated with a single handle server especially if there are mirrors involved. Note that a single keypair can be used in different roles, but it could have security implications. Here is a variabilized command I use for generating an admin keypair:
"{{ handle_dir }}/bin/hdl-keygen -alg RSA -keysize 1024
{{ handle_server_dir }}/admpriv.bin {{ handle_server_dir }}/ admpub.bin < {{ handle_dir }}/bin/passphrase"
- The keypairs should be generated on the handle server machine, and only public keys should be extracted for
security purposes (versus generating keypairs elsewhere and uploading private keys to the server).
- Once again, I recommend pre-creating config.dct, siteinfo.json, and contactdata.dct templates and populating them at runtime with actual variables.
- Certain files should be zipped to produce a sitebundle that should be sent to the hdladmin. Here are the sitebundle.zip contents:
- "{{ handle_server_dir }}/contactdata.dct"
- "{{ handle_server_dir }}/admpub.bin"
- "{{ handle_server_dir }}/siteinfo.bin" // use the
command {{ handle_dir }}/bin/hdl-convert-siteinfo <
{{ handle_server_dir }}/siteinfo.json >
{{ handle_server_dir }}/siteinfo.bin to turn siteinfo.json into siteinfo.bin
- "{{ handle_server_dir }}/repl_admin" // needed if mirroring is applicable

I recommend writing upstart scripts for Cordra and Handle, so the processes start and stop gracefully when VMs are started and stopped.

AWS:

- Cordra has two interfaces DOIP and HTTP REST. DOIP interface is accessible via IP address, and that IP address
should be recorded in the Cordra instance handle record. If REST interface is used, Cordra can be accessed using a URL.
- Handle servers are accessed via IP addresses.
- Elastic IP addresses should be used for Handle servers to ensure the IP addresses stays static across VM restarts. If DOIP interface is used, then elastic ip addresses for Cordra servers is also required; otherwise, AWS assigned domain names (which remain static across restarts) can be used. Route 53 based domain name can also be associated with Cordra instances if specific domain names are more appealing.

