# Run the Handle Server container
class handle::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $handle_run_dir = "${docker_run_dir}/handle"
	$config = lookup('handle::config.server', Hash, 'hash')
	$ports = lookup('handle::config.ports', Hash, 'hash')
	$hostports = lookup('handle::config.host_ports', Hash, 'hash')
  $volume_mount = lookup('handle::volume_mount')
  $local_admin = lookup('handle::local_admin_handle')
  $prefix = lookup('handle::config.server.assigned_prefix')

  file { $handle_run_dir:
    ensure => directory,
  }

  file { "${handle_run_dir}/config.dct":
    content => epp('handle/config.dct.epp',
		  {
        'config'                 => $config,
        'ports'                  => $ports,
        'cordra_assigned_prefix' => lookup('cordra::config.server.assigned_prefix'),
        'local_admin_handle'     => "300:${prefix}/${local_admin}",
			}
		),
    notify => Docker::Run['rpid-handle'],
  }

  file { "${handle_run_dir}/contactdata.dct":
    content => epp('handle/contactdata.dct.epp',
      {
        'admin_email'    => $config['admin_email'],
        'admin_org_name' => $config['admin_org_name'],
      },
    ),
    notify => Docker::Run['rpid-handle'],
  }

  file { "${handle_run_dir}/siteinfo.json.tmp":
    content => epp('handle/siteinfo.json.epp',
      {
        'primarysite'    => $config['primarysite'],
        'multiprimary'   => $config['multiprimary'],
        'servername'     => $config['servername'],
        'public_address' => $config['public_address'],
				'ports'          => $ports,
      },
    ),
    notify => Docker::Run['rpid-handle'],
  }

  $handle_tag = lookup('handle::handle_tag')
  docker::run { 'rpid-handle':
    ensure  => present,
    image   => "rpid-handle:${handle_tag}",
    volumes => "${handle_run_dir}:/handleserver",
    ports   => [
      "${hostports['http']}:${ports['http']}",
      "${hostports['tcp']}:${ports['tcp']}",
      "${hostports['udp']}:${ports['udp']}/udp",
    ],
  }

  firewall { '100 Allow web traffic for handle':
    proto  => 'tcp',
    dport  => $hostports['http'],
    action => 'accept',
  }

  firewall { '100 Allow tcp traffic for handle':
    proto  => 'tcp',
    dport  => $hostports['tcp'],
    action => 'accept',
  }

  firewall { '100 Allow udp traffic for handle':
    proto  => 'udp',
    dport  => $hostports['udp'],
    action => 'accept',
  }

}
