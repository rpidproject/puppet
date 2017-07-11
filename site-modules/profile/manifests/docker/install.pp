# Install Docker
class profile::docker::install {
  include docker
  include docker::compose

  # Container build/run dirs will live under here
  file { '/docker':
    ensure => directory,
  }
}
