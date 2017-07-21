# Required stuff for Icinga server
class icinga::dependencies {
  include icinga::target

  package {['libgd2-xpm-dev',
            'libdbi-dev',
            'libdbd-mysql',
            'libssl0.9.8',
            'nagios-nrpe-plugin']:
    ensure => installed,
  }

  ensure_packages(['build-essential'])

  # Allows check_nrpe to be run with multiple arguments
  file { '/etc/nagios-plugins/config/check_nrpe.cfg':
    source  => 'puppet:///modules/icinga/check_nrpe.cfg',
    require => Package['nagios-nrpe-plugin'],
  }

  file { '/usr/lib/nagios/plugins/check_ping':
    mode    => '4755',
    require => Package['nagios-plugins'],
  }

  package { [ 'php5-cli',
              'php5-ldap',
              'php-pear',
              'php5-mysql',
              'php5-xsl' ]: # for icinga-web
    ensure  => installed,
  }

  # For SSL expiry checker
  ensure_packages('curl')
}
