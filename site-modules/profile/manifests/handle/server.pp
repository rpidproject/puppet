# Run the Handle Server container
class profile::handle::server {
  include profile::docker::runner

  file { '/docker/handle':
	  ensure => directory,
	}

  file { '/docker/handle/config.dct':
	  content => 'Hello, world',
	}
		
	docker::run { 'rpid-handle':
		image   => 'rpid-handle',
		volumes => ['/docker/handle:/srv/hs1/svr1'],
	}
}
