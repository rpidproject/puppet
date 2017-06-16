# Build the Cordra Docker container
class cordra::build {
  file { [
    '/docker/cordra',
    '/docker/cordra/config/'
  ]:
    ensure => directory,
  }

  file { '/docker/cordra/Dockerfile':
    source => 'puppet:///modules/cordra/Dockerfile.cordra',
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => '/docker/cordra',
  }
}
