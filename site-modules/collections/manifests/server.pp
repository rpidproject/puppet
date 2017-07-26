# Run the Collection Services
class collections::server {
  include 'docker-compose'

  $docker_run_dir = lookup('docker_run_dir', String)
  $collections_run_dir = "${docker_run_dir}/collections"
  $data_dir = "${collections_run_dir}/data"
  $manifold_tag = lookup('collections::manifold::tag')
  $marmotta_tag = lookup('collections::marmotta::tag')
  $manifold_host_port = lookup('collections::manifold::host_port')

  file { $collections_run_dir:
    ensure => directory,
  }

  file { $data_dir:
    ensure => directory,
  }

  file { "${collections_run_dir}/docker-compose.yml":
    content => epp('collections/docker-compose.yml.epp',
      {
        'manifold_image' => "rpid-manifold:${manifold_tag}",
        'marmotta_image' => "rpid-marmotta:${marmotta_tag}",
        'postgres_image' => lookup('collections::postgres::image'),
        'manifold_host_port' => $manifold_host_port,
        'manifold_container_port' => lookup('collections::manifold::container_port'),
        'marmotta_host_port' => lookup('collections::marmotta::host_port'),
        'marmotta_container_port' => lookup('collections::marmotta::container_port'),
        'postgres_host_port' => lookup('collections::postgres::host_port'),
        'postgres_container_port' => lookup('collections::postgres::container_port'),
        'postgres_user' => lookup('collections::postgres::user'),
        'postgres_password' => lookup('collections::postgres::password'),
        'postgres_db' => lookup('collections::postgres::db'),
        'postgres_data_dir' => $data_dir,
      }
    ),
    notify => Docker::Compose["${collections_run_dir}/docker-compose.yml"],
  }

  docker::compose { "${collections_run_dir}/docker-compose.yml":
    ensure => present,
  }

  firewall { '100 Allow web traffic for collections':
    proto  => 'tcp',
    dport  => $manifold_host_port,
    action => 'accept',
  }

}
