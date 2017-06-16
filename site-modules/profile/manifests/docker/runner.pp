# Run Docker containers
class profile::docker::runner {
  include profile::docker::install

  file { lookup('docker_run_dir', String):
    ensure => directory,
  }
}
