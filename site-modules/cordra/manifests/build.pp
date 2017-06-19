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
        'http_port'  => '8080',
        'https_port' => '8443',
        'port'       => '9000',
        'ssl_port'   => '0',
      }
    ),
    notify => Docker::Image['rpid-cordra'],
  }

  file { "${cordra_build_dir}/config/repoInit.json":
    content => epp('cordra/repoInit.json.epp',
      {
        'admin_password' => lookup('cordra::admin_password', String),
        'handle_prefix'  => lookup('site::handle_prefix', String),
      }
    ),
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
  }
}
