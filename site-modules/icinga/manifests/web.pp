# Manage icinga-web
class icinga::web {
  include icinga::web_install

  $apache_pkg = hiera('apache_pkg')
  $apache_service = hiera('apache_service')
  $apache_path = hiera('apache_path')

  file { "${apache_path}/conf-available/icinga-web.conf":
    source  => 'puppet:///modules/site/icinga/icinga-web.conf.apache',
    require => Package[$apache_pkg],
  }

  file { "${apache_path}/conf-enabled/icinga-web.conf":
    ensure => symlink,
    target => "${apache_path}/conf-available/icinga-web.conf",
  }

  file { "${apache_path}/conf-enabled/nagios3.conf":
    ensure => absent,
    notify => Service[$apache_service],
  }

  firewall { '100 Allow web traffic for Icinga':
    proto  => 'tcp',
    dport  => '80',
    action => 'accept',
  }
}
