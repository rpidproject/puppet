# Build the Collection Service Components
class collections::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $collections_build_dir = "${docker_build_dir}/collections"
  $manifold_build_dir = "${docker_build_dir}/collections/perseids-manifold"
  $marmotta_build_dir = "${docker_build_dir}/collections/marmotta"
  $marmotta_port  = lookup('collections::marmotta::host_port')

  file { $collections_build_dir:
    ensure => directory,
  }

  file { $manifold_build_dir:
    ensure => directory,
  }

  file { $marmotta_build_dir:
    ensure => directory,
  }

  vcsrepo { $manifold_build_dir:
    ensure   => latest,
    revision => lookup('collections::manifold::revision'),
    provider => git,
    source   => lookup('collections::manifold::repos'),
    notify  => Exec['remove-manifold-image'],
  } 

  file { "${manifold_build_dir}/Dockerfile":
    content => epp('collections/Dockerfile.manifold.epp',
      {
        'docker_base'     => lookup('collections::manifold::docker_base'),
        'marmotta_port'   => $marmotta_port ,
        'startup_timeout' => lookup('collections::manifold::startup_timeout'),
      }
    ),
    notify  => Exec['remove-manifold-image'],
  }
   
  file { "${manifold_build_dir}/docker-entrypoint.sh":
    source => 'puppet:///modules/collections/docker-entrypoint.sh',
    require => Vcsrepo[$manifold_build_dir],
    notify  => Exec['remove-manifold-image'],
  }   

  file { "${manifold_build_dir}/compose.cfg":
    content => epp('collections/manifold.cfg.epp', {
      'marmotta_url' => "http://marmotta:${marmotta_port}/marmotta"
    }),
    require => Vcsrepo[$manifold_build_dir],
    notify  => Exec['remove-manifold-image'],
  } 

  file { "${manifold_build_dir}/gunicorn.py":
    content     => epp('collections/gunicorn.py.epp', {
      port      => lookup('collections::manifold::container_port'),
      workers   => lookup('collections::manifold::gunicorn.workers'), 
      backlog   => lookup('collections::manifold::gunicorn.backlog'),
      timeout   => lookup('collections::manifold::gunicorn.timeout'),
      keepalive => lookup('collections::manifold::gunicorn.keepalive'),
    }),
    notify  => Exec['remove-manifold-image'],
  }

  exec { 'remove-manifold-image':
      command     => "docker rmi -f rpid-manifold",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['rpid-manifold'],
  }


  docker::image { 'rpid-manifold':
    ensure     => present,
    docker_dir => $manifold_build_dir,
    notify     => Docker::Run['rpid-manifold'],
  }

  file { "${marmotta_build_dir}/Dockerfile":
    content => epp('collections/Dockerfile.marmotta.epp',
      {
        'docker_base'       => lookup('collections::marmotta::docker_base'),
        'download_url'      => lookup('collections::marmotta::download_url'),
        'postgres_port'     => lookup('collections::postgres::host_port'),
        'postgres_user'     => lookup('collections::postgres::user'),
        'postgres_password' => lookup('collections::postgres::password'),
        'postgres_db'       => lookup('collections::postgres::db'),
      }
    ),
    notify  => Exec['remove-marmotta-image'],
  }

  exec { 'remove-marmotta-image':
      command     => "docker rmi -f rpid-marmotta",
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
      timeout     => 0,
      notify      => Docker::Image['rpid-marmotta'],
  }
  
  docker::image { 'rpid-marmotta':
    ensure     => present,
    docker_dir => $marmotta_build_dir,
    notify     => Docker::Run['rpid-marmotta'],
  }

}
