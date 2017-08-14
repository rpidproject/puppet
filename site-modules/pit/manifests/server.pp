# Run the PIT API
class pit::server {

  $docker_run_dir = lookup('docker_run_dir', String)
  $pit_run_dir = "${docker_run_dir}/pit"
  $pit_tag = lookup('pit::tag')
  $pit_host_port = lookup('pit::host_port')

  file { $pit_run_dir:
    ensure => directory,
  }


  docker::run { 'rpid-pit':
    image   => "rpid-pit:${pit_tag}",
    ports   => "${pit_host_port}:8080",
  }

  firewall { '100 Allow web traffic for pit':
    proto  => 'tcp',
    dport  => $pit_host_port,
    action => 'accept',
  }

}
