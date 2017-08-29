# Build the Cordra Docker container
class cordra::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_build_dir = "${docker_build_dir}/cordra"

  file { $cordra_build_dir:
    ensure => directory,
  }

  file { "${cordra_build_dir}/Dockerfile":
    content => epp('cordra/Dockerfile.cordra.epp',
      {
        'docker_base'         => lookup('cordra::docker_base'),
        'ports'               => lookup('cordra::config.ports', Hash, 'hash'),
        'cordra_download_url' => lookup('cordra::download_url'),
      }
    ),
    notify => Exec['remove-cordra-image'],
  }

  exec { 'remove-cordra-image':
      command     => "docker rmi -f rpid-cordra",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['rpid-cordra'],
  }
  
  docker::image { 'rpid-cordra':
    ensure      => present,
    docker_dir  => $cordra_build_dir,
    notify      => Docker::Run['rpid-cordra'],
  }
}
