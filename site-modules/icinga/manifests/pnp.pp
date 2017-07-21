# Install PNP4Nagios (graphing library)
class icinga::pnp {
  include apache_bc

  $apache_pkg = hiera('apache_pkg')
  $apache_service = hiera('apache_service')
  $apache_path = hiera('apache_path')
  $pnp_url_base = hiera('pnp4nagios_url_base')
  $pnp_version = hiera('pnp4nagios_version')

  package { [ 'rrdtool',
              'php5',
              'php5-gd']:
    ensure => installed,
    notify => Exec['build-pnp'],
  }

  realize(User::Bundle['icinga'])

  exec { 'build-pnp':
    cwd       => '/root',
    command   => "/usr/bin/wget ${pnp_url_base}/pnp4nagios-${pnp_version}.tar.gz && /bin/tar xvzf pnp4nagios-${pnp_version}.tar.gz && cd pnp4nagios-${pnp_version} && ./configure --with-nagios-user=icinga --with-nagios-group=icinga && make all && make install",
    creates   => '/usr/local/pnp4nagios',
    require   => [Package['build-essential'], User::Bundle['icinga']],
    logoutput => on_failure,
  }

  file { "${apache_path}/conf-available/pnp4nagios.conf":
    source  => 'puppet:///modules/icinga/pnp4nagios.conf',
    notify  => Service[$apache_service],
    require => [Package[$apache_pkg], Package['php5']],
  }

  file { "${apache_path}/conf-enabled/pnp4nagios.conf":
    ensure => symlink,
    target => "${apache_path}/conf-available/pnp4nagios.conf",
  }

  file { '/usr/local/pnp4nagios/etc/check_commands/check_nrpe.cfg':
    source  => 'puppet:///modules/icinga/check_nrpe.pnp4nagios.cfg',
    require => Exec['build-pnp'],
  }

  file { '/usr/local/icinga/share/ssi/status-header.ssi':
    mode    => '0644',
    owner   => 'icinga',
    group   => 'icinga',
    source  => 'puppet:///modules/icinga/status-header.ssi',
    require => Exec['build-icinga-core'],
    notify  => Exec['icinga-config-check'],
  }
}
