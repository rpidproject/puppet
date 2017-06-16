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
    source => 'puppet:///modules/cordra/Dockerfile.cordra',
    notify => Docker::Image['rpid-cordra'],
  }

  file { "${cordra_build_dir}/config/config.json":
    content => epp('cordra/config.json.epp',
      {
        'zookeeper_host' => lookup('cordra::zookeeper_host', String),
        'mongodb_host'   => lookup('cordra::mongodb_host', String),
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

  file { "${cordra_build_dir}/config/web.xml":
    content => epp('cordra/web.xml.epp',
      {
        'zookeeper_host' => lookup('cordra::zookeeper_host', String),
      }
    ),
    notify => Docker::Image['rpid-cordra'],
  }

  docker::image { 'rpid-cordra':
    ensure     => latest,
    docker_dir => $cordra_build_dir,
  }
}
