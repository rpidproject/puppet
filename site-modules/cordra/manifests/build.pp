# Build the Cordra Docker container
class cordra::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_build_dir = "${docker_build_dir}/cordra"
  $assigned_prefix = lookup('cordra::config.server.assigned_prefix',String)
  $admin_idx = lookup('handle::config.server.admin_idx')
  $site_handle = lookup('site::handle_prefix')
  $handle_admin_id = "${$admin_idx}/${site_handle}"
  $handle_run_dir = "${docker_run_dir}/handle"
  $handle_admin_key = "${handle_run_dir}/handle/admpriv.bin" 
  $cordra_user = 'cordra'

  file { $cordra_build_dir:
    ensure => directory,
  }

  file { "${cordra_build_dir}/handle":
    ensure  => directory,
    require => File[$cordra_build_dir],
  }

  file { "${cordra_build_dir}/handle/siteinfo.json":
    ensure  => directory,
    source  => "${handle_run_dir}/siteinfo.json",
    require    => Docker::Run['rpid-handle'],
  }

  file { "${cordra_build_dir}/handle/admpriv.bin":
    ensure  => directory,
    source  => "${handle_run_dir}/admpriv.bin",
  }

  file { "${cordra_build_dir}/docker-entrypoint.sh":
    source  => 'puppet:///modules/cordra/docker-entrypoint.sh',
    require => File[$cordra_build_dir],
    notify  => Docker::Image['rpid-cordra'],
  }

  file { "${cordra_build_dir}/setup.cmd":
    content => epp('cordra/setup.cmd.epp',
      {
        'assigned_prefix'  => $assigned_prefix,
        'handle_admin_id'  => $handle_admin_id,
        'handle_admin_key' => '/cordra/handle/admpriv.bin',
      }
    ),
    notify  => Docker::Image['rpid-cordra'],
  }

  file { "${cordra_build_dir}/Dockerfile":
    content => epp('cordra/Dockerfile.cordra.epp',
      {
        'docker_base'         => lookup('cordra::docker_base'),
        'ports'               => lookup('cordra::config.ports', Hash, 'hash'),
        'cordra_download_url' => lookup('cordra::download_url'),
        'cordra_user'         => $cordra_user,
      }
    ),
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
  }
}
