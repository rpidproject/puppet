# Install PNP4Nagios (graphing library)
class icinga::pnp {
  include php

  $pnp_url_base = lookup('pnp4nagios_url_base', String[1])
  $pnp_version = lookup('pnp4nagios_version', String[1])

  ensure_packages([
    'libssl1.1',
    'libssl-dev',
    'php-gd',
    'rrdtool',
  ])

  exec { 'build-pnp':
    cwd       => '/root',
    command   => "/usr/bin/wget ${pnp_url_base}/pnp4nagios-${pnp_version}.tar.gz && /bin/tar xvzf pnp4nagios-${pnp_version}.tar.gz && cd pnp4nagios-${pnp_version} && ./configure --with-nagios-user=icinga --with-nagios-group=icinga && make all && make install",
    creates   => '/usr/local/pnp4nagios',
    logoutput => on_failure,
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
