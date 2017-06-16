# Run the Cordra container
class cordra::server {
  file { [
    '/docker/cordra',
    '/docker/cordra/config/'
  ]:
    ensure => directory,
  }

  file { '/docker/cordra/docker-compose.yml':
    content => epp('profile/cordra/docker-compose.yml.epp',
      {
        'zookeeper_host' => hiera('cordra::zookeeper_host'),
        'mongodb_host'   => hiera('cordra::mongodb_host'),
      }
    ),
    notify  => Docker_compose['/docker/cordra/docker-compose.yml']
  }

  file { '/docker/cordra/config/config.json':
    content => epp('profile/cordra/config.json.epp',
      {
        'zookeeper_host' => hiera('cordra::zookeeper_host'),
        'mongodb_host'   => hiera('cordra::mongodb_host'),
      }
    ),
    notify  => Docker_compose['/docker/cordra/docker-compose.yml']
  }

  file { '/docker/cordra/config/repoInit.json':
    content => epp('profile/cordra/repoInit.json.epp',
      {
        'admin_password' => hiera('cordra::admin_password'),
        'handle_prefix'  => hiera('site::handle_prefix'),
      }
    ),
    notify  => Docker_compose['/docker/cordra/docker-compose.yml']
  }

  file { '/docker/cordra/config/web.xml':
    content => epp('profile/cordra/web.xml.epp',
      {
        'zookeeper_host' => hiera('cordra::zookeeper_host'),
      }
    ),
    notify  => Docker_compose['/docker/cordra/docker-compose.yml']
  }

  docker_compose { '/docker/cordra/docker-compose.yml':
    ensure => present,
  }
}
