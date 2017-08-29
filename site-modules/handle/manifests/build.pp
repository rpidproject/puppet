# Build the Handle Server Docker image
class handle::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $handle_build_dir = "${docker_build_dir}/handle"
  $admin_idx = lookup('handle::config.server.admin_idx')
  $site_handle = lookup('site::handle_prefix')
  $admin_id = "${$admin_idx}/${site_handle}"

  file { $handle_build_dir:
    ensure => directory,
  }

  file { "${handle_build_dir}/Dockerfile":
    content => epp('handle/Dockerfile.handle.epp',
      {
        'docker_base'         => lookup('handle::docker_base'),
        'handle_download_url' => lookup('handle::download_url'),
        'handle_user'         => lookup('handle::user'),
        'ports'               => lookup('handle::config.ports'),
        'handle_prefix'       => lookup('site::handle_prefix'),
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
