# Enable a machine to be monitored by Icinga
class icinga::target {
  archive { '/root/nagios-nrpe-server.deb':
    source  => 'https://www.claudiokuenzler.com/downloads/nrpe/nagios-nrpe-server_2.15-1ubuntu2_amd64.xenial.deb',
    extract => false,
  }

  package { 'nagios-nrpe-server':
    ensure   => installed,
    provider => 'dpkg',
    source   => '/root/nagios-nrpe-server.deb',
  }

  package { [ 'nagios-plugins',
              'nagios-plugins-basic',
              'nagios-plugins-standard',
              'nagios-plugins-extra' ]:
    ensure => installed,
  }

  service { 'nagios-nrpe-server':
    ensure    => running,
    enable    => true,
    pattern   => '/usr/sbin/nrpe',
    require   => Package['nagios-nrpe-server'],
    hasstatus => false,
  }

  file { '/etc/nagios/nrpe.cfg':
    content => epp('icinga/nrpe.cfg.epp',
    {
      monitor_ips       => hiera('monitor_ips'),
    }),
    require => Package['nagios-nrpe-server'],
    notify  => Service['nagios-nrpe-server'],
  }

  file { '/usr/lib/nagios/plugins/bitfield':
    source             => 'puppet:///modules/site/icinga/plugins',
    recurse            => remote,
    source_permissions => use,
    mode               => '0755',
    require            => Package['nagios-plugins'],
  }

  firewall { '000 NRPE':
    proto  => 'tcp',
    dport  => '5666',
    action => 'accept',
  }
}
