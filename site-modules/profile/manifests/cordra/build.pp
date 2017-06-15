# Build the Handle Server Docker image
class profile::cordra::build {
  include 'docker'
  include 'docker::compose'

  file { '/docker': 
    ensure => directory,
  }

  file { '/docker/cordra':
    ensure => directory,
  }

  file { '/docker/cordra/config/':
    ensure => directory,
  }

  file { '/docker/cordra/Dockerfile':
    source => 'puppet:///modules/profile/cordra/Dockerfile.cordra',
    notify => Docker::Image['rpid-cordra'],
  }

  file { '/docker/cordra/docker-compose.yml':
    content => epp('profile/cordra/docker-compose.yml.epp', {
      'zookeeper_host' => hiera('cordra::zookeeper_host'),
      'mongodb_host'   => hiera('cordra::mongodb_host'),
    }),
    notify => Docker_compose['/docker/cordra/docker-compose.yml']
  }

  file { '/docker/cordra/config/config.json':
    content => epp('profile/cordra/config.json.epp', {
      'zookeeper_host' => hiera('cordra::zookeeper_host'),
      'mongodb_host'   => hiera('cordra::mongodb_host'),
    }),
    notify => Docker::Image['rpid-cordra'],
  }

  file { '/docker/cordra/config/repoInit.json':
    content => epp('profile/cordra/repoInit.json.epp', {
      'admin_password' => hiera('cordra::admin_password'),
      'handle_prefix'  => hiera('site::handle_prefix'),
    }),
    notify => Docker::Image['rpid-cordra'],
  }

  file { '/docker/cordra/config/web.xml':
    content => epp('profile/cordra/web.xml.epp', {
      'zookeeper_host' => hiera('cordra::zookeeper_host'),
    }),
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure      => latest,
    docker_dir => '/docker/cordra',
  }

  docker::image {'zookeeper':
    ensure => latest
  }

  docker::image {'mongo':
    ensure => latest
  }

  docker_compose { '/docker/cordra/docker-compose.yml':
    ensure => present,
  }
}
