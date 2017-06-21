# Build the Cordra Docker container
class cordra::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $cordra_build_dir = "${docker_build_dir}/cordra"

  file { [
    $cordra_build_dir,
    "${cordra_build_dir}/config"
  ]:
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
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
  }
}
