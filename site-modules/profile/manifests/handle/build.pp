# Build the Handle Server Docker image
class profile::handle::build {
  file { '/tmp/Dockerfile.handle':
    source => 'puppet:///modules/profile/handle/Dockerfile.handle',
    notify => Docker::Image['rpid-handle'],
  }

  docker::image { 'rpid-handle':
    ensure      => latest,
    docker_file => '/tmp/Dockerfile.handle',
  }
}
