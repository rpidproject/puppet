# Run the Cordra container
class cordra::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_run_dir = "${docker_run_dir}/cordra"
  $cordra_data_dir = "${cordra_run_dir}/data"
  $cordra_tag = lookup('cordra::cordra_tag', String)
	$ports = lookup('cordra::config.ports', Hash, 'hash')
	$hostports = lookup('cordra::config.host_ports', Hash, 'hash')
  $assigned_prefix = lookup('cordra::config.server.assigned_prefix',String)
  $admin_idx = lookup('handle::config.server.admin_idx')
  $site_handle = lookup('site::handle_prefix')
  $handle_admin_id = "${$admin_idx}/${site_handle}"
  $cordra_data_mount = '/data'
  $handle_run_dir = "${docker_run_dir}/handle"

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
        'admin_password'  => lookup('cordra::admin_password'),
        'handle_prefix'   => $assigned_prefix,
        'handle_admin_id' => $handle_admin_id,
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
        'assigned_prefix' => $assigned_prefix,
        'admin_handle'    => $handle_admin_id,
      }
    ),
  }

  file { "${cordra_data_dir}/configure.cmd":
    content => epp('cordra/configure.cmd.epp', 
      {
        'assigned_prefix'  => $assigned_prefix,
        'handle_admin_id'  => $handle_admin_id,
        'handle_admin_key' => "${cordra_data_mount}/admpriv.bin",
      }
    ),
  }

  file { "${cordra_data_dir}/configure.sh":
    content => epp('cordra/configure.sh.epp', 
      {
        'handle_run_dir'    => $handle_run_dir,
        'cordra_data_host'  => $cordra_data_dir,
        'cordra_data_mount' => $cordra_data_mount,
      }
    ),
    mode => "0755",
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
    require   => Docker::Image['rpid-cordra'],
  }

  firewall { '100 Allow https traffic for cordra':
    proto  => 'tcp',
    dport  => $hostports['https'],
    action => 'accept',
  }

  firewall { '100 Allow http traffic for cordra':
    proto  => 'tcp',
    dport  => $hostports['http'],
    action => 'accept',
  }

  firewall { '100 Allow server traffic for cordra':
    proto  => 'tcp',
    dport  => $hostports['server'],
    action => 'accept',
  }

  firewall { '100 Allow ssl traffic for cordra':
    proto  => 'tcp',
    dport  => $hostports['ssl'],
    action => 'accept',
  }
}
