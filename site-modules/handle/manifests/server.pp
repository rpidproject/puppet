# Run the Handle Server container
class handle::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $handle_run_dir = "${docker_run_dir}/handle"
	$config = lookup('handle::config.server', Hash, 'hash')
	$ports = lookup('handle::config.ports', Hash, 'hash')

  file { $handle_run_dir:
    ensure => directory,
  }

  file { "${handle_run_dir}/config.dct":
    content => epp('handle/config.dct.epp',
		  {
        'config' => $config,
        'ports'  => $ports,
			}
		),
  }

  file { "${handle_run_dir}/contactdata.dct":
    content => epp('handle/contactdata.dct.epp',
      {
        'admin_email'    => $config['admin_email'],
        'admin_org_name' => $config['admin_org_name'],
      },
    ),
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
  }

  $handle_tag = lookup('handle::handle_tag')
  docker::run { 'rpid-handle':
    image   => "rpid-handle:${handle_tag}",
    volumes => "${handle_run_dir}:/handleserver",
    ports   => [
      $ports['http'],
      $ports['tcp'],
      "${ports['udp']}/udp",
    ],
  }
}
