# Build the Handle Server Docker image
class handle::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $handle_build_dir = "${docker_build_dir}/handle"
  $admin_idx = lookup('handle::config.server.admin_idx')
  $site_handle = lookup('site::handle_prefix')
  $admin_id = "${$admin_idx}/${site_handle}"
  $prefix = lookup('site::handle_prefix')

  file { $handle_build_dir:
    ensure => directory,
  }

  file { "${handle_build_dir}/admin_batchfile":
    content => epp('handle/admin_batchfile.epp',
      {
        'admin_id' => $admin_id,
        'prefix'   => $prefix,
        'handle'   => lookup('handle::local_admin_handle'),
        'password' => lookup('handle::local_admin_password'), 
      }
    ),
    notify  => Exec['remove-handle-image'],
  }

  file { "${handle_build_dir}/Dockerfile":
    content => epp('handle/Dockerfile.handle.epp',
      {
        'docker_base'         => lookup('handle::docker_base'),
        'handle_download_url' => lookup('handle::download_url'),
        'handle_user'         => lookup('handle::user'),
        'ports'               => lookup('handle::config.ports'),
        'handle_prefix'       => $prefix,
        'handle_admin_id'     => $admin_id,
      }
    ),
    notify  => Exec['remove-handle-image'],
  }

  exec { 'remove-handle-image':
      command     => "docker rmi -f rpid-handle",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['rpid-handle'],
  }

  docker::image { 'rpid-handle':
    ensure     => present,
    docker_dir => $handle_build_dir,
    notify     => Docker::Run['rpid-handle'],
  }
}
