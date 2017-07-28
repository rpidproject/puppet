# Build the Cordra Docker container
class cordra::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_build_dir = "${docker_build_dir}/cordra"
  $handle_admin_id = lookup('handle::config.server.admin_id',String)
  $handle_admin_key = "${docker_run_dir}/handle/admpriv.bin" 
  $assigned_prefix = lookup('cordra::config.server.assigned_prefix',String)

  file { $cordra_build_dir:
    ensure => directory,
  }

  file { "${cordra_build_dir}/docker-entrypoint.sh":
    source  => 'puppet:///modules/cordra/docker-entrypoint.sh',
    require => File[$cordra_build_dir],
    notify  => Docker::Image['rpid-cordra'],
  }

  file { "${cordra_build_dir}/setup.cfg":
    content => epp('cordra/setup.cfg.epp',
      {
        'assigned_prefix'  => $assigned_prefix,
        'handle_admin_id'  => $handle_admin_id,
        'handle_admin_key' => $handle_admin_key,
      }
    ),
  }

  file { "${cordra_build_dir}/Dockerfile":
    content => epp('cordra/Dockerfile.cordra.epp',
      {
        'docker_base'         => lookup('cordra::docker_base'),
        'ports'               => lookup('cordra::config.ports', Hash, 'hash'),
        'cordra_download_url' => lookup('cordra::download_url'),
      }
    ),
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
    require    => Docker::Image['rpid-handle'],
  }
}
