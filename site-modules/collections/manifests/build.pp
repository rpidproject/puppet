# Build the Collection Service Components
class collections::build {
  $docker_build_dir = lookup('docker_build_dir', String)
  $collections_build_dir = "${docker_build_dir}/collections"
  $manifold_build_dir = "${docker_build_dir}/collections/perseids-manifold"
  $marmotta_build_dir = "${docker_build_dir}/collections/marmotta"

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
  } 

  file { "${manifold_build_dir}/Dockerfile":
    content => epp('collections/Dockerfile.manifold.epp',
      {
        'docker_base'     => lookup('collections::manifold::docker_base'),
        'marmotta_port'   => lookup('collections::marmotta::host_port'),
        'startup_timeout' => lookup('collections::manifold::startup_timeout'),
      }
    ),
    notify  => Docker::Image['rpid-manifold'],
  }

  docker::image { 'rpid-manifold':
    ensure     => latest,
    docker_dir => $manifold_build_dir,
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
    notify  => Docker::Image['rpid-marmotta'],
  }

  docker::image { 'rpid-marmotta':
    ensure     => latest,
    docker_dir => $marmotta_build_dir,
  }

}
