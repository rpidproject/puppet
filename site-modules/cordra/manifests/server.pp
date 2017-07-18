# Run the Cordra container
class cordra::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_run_dir = "${docker_run_dir}/cordra"
  $cordra_data_dir = "${cordra_run_dir}/data"
  $cordra_tag = lookup('cordra::cordra_tag', String)
	$ports = lookup('cordra::config.ports', Hash, 'hash')
	$hostports = lookup('cordra::config.host_ports', Hash, 'hash')

  file { [
    $cordra_run_dir,
    $cordra_data_dir,
    "${cordra_data_dir}/knowbots",
  ]:
    ensure => directory,
  }

  file { "${cordra_data_dir}/repoInit.json":
    content => epp('cordra/repoInit.json.epp', 
      {
        'admin_password' => lookup('cordra::admin_password'),
        'handle_prefix'  => lookup('site::handle_prefix'),
      }
    ),
  }

  file { "${cordra_data_dir}/config.dct":
    content => epp('cordra/config.dct.epp',
      {
        'ports'  => lookup('cordra::config.ports', Hash, 'hash'),
        'server' => lookup('cordra::config.server', Hash, 'hash'),
      }
    ),
  }

  file { "${cordra_data_dir}/password.dct":
    content => epp('cordra/password.dct.epp', 
      {
        'admin_password' => lookup('cordra::admin_password'),
      }
    )
  }

  file { "${cordra_data_dir}/serverinfo.xml":
    content => epp('cordra/serverinfo.xml.epp', 
      {
        'serverid'       => lookup('cordra::config.server.serverid'),
        'servername'     => lookup('cordra::config.server.servername'),
        #'public_address' => lookup('cordra::config.server.public_address'),
        'port'           => lookup('cordra::config.ports.server'),
      }
    )
  }

  file { "${cordra_data_dir}/knowbots/config.dct":
    content => epp('cordra/knowbots.config.dct.epp', 
      {
        'assigned_prefix' => lookup('site::handle_prefix'),
        'admin_handle'    => lookup('site::handle_prefix'),
      }
    )
  }


  docker::run { 'rpid-cordra':
    ensure => present,
    image   => "rpid-cordra:${cordra_tag}",
    volumes => ["${cordra_data_dir}:/data"],
    ports   => [ 
      "${hostports['https']}:${ports['https']}",
      "${hostports['http']}:${ports['http']}",
      "${hostports['server']}:${ports['server']}",
      "${hostports['ssl']}:${ports['ssl']}",
    ],
  }
}
