# Build Docker containers
class profile::docker::builder {
  include profile::docker::install

  file { lookup('docker_build_dir', String):
    ensure => directory,
  }
}
