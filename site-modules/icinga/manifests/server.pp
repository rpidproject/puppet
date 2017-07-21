# Be the Icinga server
class icinga::server {
  $icinga_version = lookup('icinga::version', String)

  include icinga::dependencies
  include icinga::pnp
  include icinga::web
  include icinga::classic
  include icinga::config
  include icinga::radiator

  user { 'icinga': ensure => present }

  archive { 'icinga-core':
    path         => "/root/icinga-core-${icinga_version}.tar.gz",
    source       => "https://codeload.github.com/Icinga/icinga-core/tar.gz/v${icinga_version}",
    extract      => true,
    extract_path => '/root',
    cleanup      => true,
  }

  exec { 'build-icinga-core':
    cwd       => "/root/icinga-core-${icinga_version}",
    command   => "/root/icinga-core-${icinga_version}/configure --with-icinga-user=icinga --with-command-user=icinga --with-command-group=apache --enable-idoutils --libexecdir=/usr/lib64/nagios/plugins && /usr/bin/make all && /usr/bin/make fullinstall",
    creates   => '/usr/local/icinga',
    require   => Archive['icinga-core'],
    logoutput => on_failure,
  }

  service { 'icinga':
    ensure   => running,
    enable   => true,
    provider => redhat,
    require  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/htpasswd.users':
    source  => 'puppet:///modules/icinga/htpasswd.icinga',
    require => Exec['build-icinga-core'],
  }

  exec { 'download-nrpe':
    cwd     => '/root',
    command => '/usr/bin/wget http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-2.12.tar.gz && /bin/tar xvzf nrpe-2.12.tar.gz',
    creates => '/root/nrpe-2.12',
  }

  exec { 'build-nrpe':
    cwd     => '/root/nrpe-2.12',
    command => '/root/nrpe-2.12/configure --with-nrpe-user=icinga --with-nrpe-group=icinga --with-nagios-user=icinga --with-nagios-group=icinga --libexecdir=/usr/lib64/nagios/plugins && make all && make install-plugin',
    creates => '/usr/lib64/nagios/plugins/check_nrpe',
    require => [Exec['download-nrpe'],
                Package['nagios-common'],
                Package['openssl'],
                Class['admin::devtools']],
  }

  file { '/usr/local/icinga/var/rw/':
    ensure  => directory,
    owner   => 'icinga',
    require => Exec['build-icinga-core'],
  }

  file { '/usr/local/icinga/var/rw/icinga.cmd':
    group  => 'apache',
  }

  file { '/usr/local/icinga/var/icinga.log':
    ensure => present,
    mode   => '0644',
    owner  => 'icinga',
    group  => 'icinga',
  }

  firewall { '100 Allow NRPE out':
    chain  => 'OUTPUT',
    proto  => 'tcp',
    dport  => '5666',
    action => 'accept',
  }
}
