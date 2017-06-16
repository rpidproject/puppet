# Build the Cordra Docker container
class cordra::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $cordra_build_dir = "${docker_build_dir}/cordra"

  file { $cordra_build_dir:
    ensure => directory,
  }

  file { "${cordra_build_dir}/Dockerfile":
    source => 'puppet:///modules/cordra/Dockerfile.cordra',
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
  }
}
