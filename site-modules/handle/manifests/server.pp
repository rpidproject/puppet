# Run the Handle Server container
class handle::server {
  file { '/docker/handle':
    ensure => directory,
  }
  
  file { '/docker/handle/config.dct':
    content => epp('handle/config.dct.epp', hiera('handle::config')),
  }
    
  docker::run { 'rpid-handle':
    image   => 'rpid-handle',
    volumes => ['/docker/handle:/srv/hs1/svr1'],
  }
}
