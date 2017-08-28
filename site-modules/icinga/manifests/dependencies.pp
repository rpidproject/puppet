# Required stuff for Icinga server
class icinga::dependencies {
  include icinga::target
  include profile::slacksay

  package {['libgd-dev',
            'libdbi-dev',
            'libdbd-mysql',
            'libssl1.1',
            'nagios-nrpe-plugin']:
    ensure => installed,
  }

  ensure_packages([
    'build-essential',
    'mailutils',
  ])

  # Allows check_nrpe to be run with multiple arguments
  file { '/etc/nagios-plugins/config/check_nrpe.cfg':
    source  => 'puppet:///modules/icinga/check_nrpe.cfg',
    require => Package['nagios-nrpe-plugin'],
  }

  file { '/usr/lib/nagios/plugins/check_ping':
    mode    => '4755',
    require => Package['monitoring-plugins'],
  }

  # For SSL expiry checker
  ensure_packages('curl')
}
