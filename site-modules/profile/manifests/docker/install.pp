# Install Docker
class profile::docker::install {
  include docker
  include docker::compose

  # Container build dirs, support files, etc, will live under here
  file { '/docker':
    ensure => directory,
  }
}
