# Run Docker containers
class profile::docker::runner {
  include profile::docker::install

  # Container support files, etc, will live under here
  file { '/docker':
    ensure => directory,
  }
}
