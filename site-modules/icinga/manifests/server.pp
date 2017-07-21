# Be the Icinga server
class icinga::server {
  $icinga_version = hiera('icinga::version')

  include apache_bc
  include icinga::dependencies
  include icinga::pnp
  include icinga::web
  include icinga::classic

  realize(User::Bundle['icinga'])

  utils::remote_file { "/root/icinga-${icinga_version}.tar.gz":
    source  => "http://sourceforge.net/projects/icinga/files/icinga/${icinga_version}/icinga-${icinga_version}.tar.gz/download",
    require => Class['icinga::dependencies'],
  }

  exec { 'unpack-icinga-core':
    cwd       => '/root',
    command   => "/bin/tar xvf icinga-${icinga_version}.tar.gz",
    creates   => "/root/icinga-${icinga_version}",
    require   => Utils::Remote_file["/root/icinga-${icinga_version}.tar.gz"],
    logoutput => false,
  }

  exec { 'build-icinga-core':
    cwd       => "/root/icinga-${icinga_version}",
    command   => "/root/icinga-${icinga_version}/configure --with-icinga-user=icinga --with-command-user=icinga --with-command-group=www-data --enable-idoutils --libexecdir=/usr/lib/nagios/plugins && /usr/bin/make all && /usr/bin/make fullinstall",
    creates   => '/usr/local/icinga',
    require   => Exec['unpack-icinga-core'],
    logoutput => on_failure,
  }

  service { 'icinga':
    ensure  => running,
    enable  => true,
    require => Exec['icinga-config-check'],
  }

  exec { 'download-nrpe':
    cwd     => '/root',
    command => '/usr/bin/wget http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-2.12.tar.gz && /bin/tar xvzf nrpe-2.12.tar.gz',
    creates => '/root/nrpe-2.12',
  }

  exec { 'build-nrpe':
    cwd     => '/root/nrpe-2.12',
    command => '/root/nrpe-2.12/configure --with-nrpe-user=icinga --with-nrpe-group=icinga --with-nagios-user=icinga --with-nagios-group=icinga --libexecdir=/usr/lib/nagios/plugins && make all && make install-plugin',
    creates => '/usr/lib/nagios/plugins/check_nrpe',
    require => [Exec['download-nrpe'], Package['nagios-plugins'], Package['libssl0.9.8']],
  }

  file { '/usr/local/icinga/var/rw/icinga.cmd':
    owner   => 'www-data',
    group   => 'www-data',
    require => Exec['build-icinga-core'],
  }

  exec { 'icinga-config-check':
    command     => '/usr/local/icinga/bin/icinga -v /usr/local/icinga/etc/icinga.cfg && /usr/sbin/service icinga reload',
    refreshonly => true,
  }

  firewall { '100 Allow NRPE out':
    chain  => 'OUTPUT',
    proto  => 'tcp',
    dport  => '5666',
    action => 'accept',
  }
}
