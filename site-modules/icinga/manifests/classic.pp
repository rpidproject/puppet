# Configure Apache for Icinga server
class icinga::classic {
  $apache_pkg = hiera('apache_pkg')
  $apache_service = hiera('apache_service')
  $apache_path = hiera('apache_path')

  file { '/etc/apache2/sites-available/icinga.conf':
    source  => 'puppet:///modules/site/icinga/icinga.conf.apache',
    notify  => Exec['enable-icinga-vhost'],
    require => Package[$apache_pkg],
  }

  exec { 'enable-icinga-vhost':
    command     => '/usr/sbin/a2ensite icinga.conf',
    require     => [File["${apache_path}/sites-available/icinga.conf"], Package[$apache_pkg]],
    refreshonly => true,
    notify      => Service[$apache_service],
  }

  exec { 'enable-cgi':
    command => '/usr/sbin/a2enmod cgi',
    creates => "${apache_path}/mods-enabled/cgi.load",
    require => Package[$apache_pkg],
    notify  => Service[$apache_service],
  }
}
