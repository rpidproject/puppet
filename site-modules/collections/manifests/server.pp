# Run the Collection Services
class collections::server {

  $docker_run_dir = lookup('docker_run_dir', String)
  $collections_run_dir = "${docker_run_dir}/collections"
  $data_dir = "${collections_run_dir}/data"
  $manifold_tag = lookup('collections::manifold::tag')
  $marmotta_tag = lookup('collections::marmotta::tag')
  $postgres_tag = lookup('collections::postgres::tag')
  $manifold_host_port = lookup('collections::manifold::host_port')
  $manifold_container_port = lookup('collections::manifold::container_port')
  $marmotta_host_port = lookup('collections::marmotta::host_port')
  $postgres_host_port = lookup('collections::postgres::host_port')
  $postgres_user = lookup('collections::postgres::user')
  $postgres_password = lookup('collections::postgres::password')
  $postgres_db = lookup('collections::postgres::db')

  file { $collections_run_dir:
    ensure => directory,
  }

  file { $data_dir:
    ensure => directory,
  }

  # this should all be handled via docker compose but puppet and docker compose
  # are not playing well together. it was only starting the postgres container

  docker::run { 'rpid-postgres':
    image   => "postgres:${postgres_tag}",
    ports   => "${postgres_host_port}:5432",
    env     => [ "POSTGRES_PASSWORD=${postgres_password}",
                 "POSTGRES_USER=$postgres_user",
                 "PGDATA=/data",
               ],
    volumes => "${data_dir}:/data",
  }

  docker::run { 'rpid-marmotta':
    image => "rpid-marmotta:${marmotta_tag}",
    ports => "${marmotta_host_port}:8080",
    links => [ "rpid-postgres:postgres"],
    require => [ Docker::Run['rpid-postgres'], Docker::Image['rpid-marmotta'] ],
  }

  docker::run { 'rpid-manifold':
    image   => "rpid-manifold:${manifold_tag}",
    ports   => "${manifold_host_port}:${manifold_container_port}",
    env     => [ "COLLECTIONS_API_SETTINGS=compose.cfg"],
    links   => [ "rpid-marmotta:marmotta" ] ,
    require => [ Docker::Run['rpid-marmotta'], Docker::Image['rpid-manifold'] ],
    command => "/app/wait-for-it.sh -h http://marmotta:${marmotta_host_port}/marmotta -t 60 -- python3 run.py" 
  }

  firewall { '100 Allow web traffic for collections':
    proto  => 'tcp',
    dport  => $manifold_host_port,
    action => 'accept',
  }

}
