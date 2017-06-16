# Run the Cordra container
class cordra::server {
  $docker_run_dir = lookup('docker_run_dir', String)
  $cordra_run_dir = "${docker_run_dir}/cordra"

  file { [
    $cordra_run_dir,
    "${cordra_run_dir}/config"
  ]:
    ensure => directory,
  }

  file { "${cordra_run_dir}/docker-compose.yml":
    content => epp('cordra/docker-compose.yml.epp',
      {
        'zookeeper_host' => lookup('cordra::zookeeper_host', String),
        'mongodb_host'   => lookup('cordra::mongodb_host', String),
        'config_dir'     => "${cordra_run_dir}/config",
      }
    ),
    notify  => Docker_compose["${cordra_run_dir}/docker-compose.yml"]
  }

  file { "${cordra_run_dir}/config/config.json":
    content => epp('cordra/config.json.epp',
      {
        'zookeeper_host' => lookup('cordra::zookeeper_host', String),
        'mongodb_host'   => lookup('cordra::mongodb_host', String),
      }
    ),
    notify  => Docker_compose["${cordra_run_dir}/docker-compose.yml"]
  }

  file { "${cordra_run_dir}/config/repoInit.json":
    content => epp('cordra/repoInit.json.epp',
      {
        'admin_password' => lookup('cordra::admin_password', String),
        'handle_prefix'  => lookup('site::handle_prefix', String),
      }
    ),
    notify  => Docker_compose["${cordra_run_dir}/docker-compose.yml"]
  }

  file { "${cordra_run_dir}/config/web.xml":
    content => epp('cordra/web.xml.epp',
      {
        'zookeeper_host' => lookup('cordra::zookeeper_host', String),
      }
    ),
    notify  => Docker_compose["${cordra_run_dir}/docker-compose.yml"]
  }

  docker_compose { "${cordra_run_dir}/docker-compose.yml":
    ensure => present,
  }
}
