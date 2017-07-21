# Be the Icinga server
class icinga::server {
  $icinga_version = lookup('icinga::version', String)

  include icinga::dependencies
  include icinga::pnp
  include icinga::web
  include icinga::classic
  include icinga::config

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
    require  => Exec['icinga-config-check'],
  }

  file { '/usr/local/icinga/etc/htpasswd.users':
    source  => 'puppet:///modules/icinga/htpasswd.icinga',
    require => Exec['build-icinga-core'],
  }

  ensure_packages(['nagios-nrpe-plugin'])

  file { '/usr/local/icinga/var/rw/':
    ensure  => directory,
    owner   => 'icinga',
    require => Exec['build-icinga-core'],
  }

  file { '/usr/local/icinga/var/rw/icinga.cmd':
    group  => 'www-data',
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
